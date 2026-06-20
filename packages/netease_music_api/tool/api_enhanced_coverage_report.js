#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
const vm = require('vm')
const { execFileSync } = require('child_process')

const repoRoot = path.resolve(__dirname, '../../..')
const upstreamRepoPath = path.join(repoRoot, 'third_party/api-enhanced')
const upstreamPackagePath = path.join(upstreamRepoPath, 'package.json')
const upstreamModuleDir = path.join(upstreamRepoPath, 'module')
const generatedManifestPath = path.join(
  repoRoot,
  'packages/netease_music_api/lib/src/generated/api_enhanced_modules.g.dart',
)
const oracleScriptPath = path.join(repoRoot, 'packages/netease_music_api/tool/api_enhanced_node_oracle.js')
const specialCoveragePath = path.join(repoRoot, 'packages/netease_music_api/tool/api_enhanced_special_coverage.json')
const jsonOutput = process.argv.includes('--json')

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'))
}

function loadManifestEntries() {
  const source = fs.readFileSync(generatedManifestPath, 'utf8')
  const listStart = source.indexOf('const List<ApiEnhancedModule> apiEnhancedModules')
  const mapStart = source.indexOf('const Map<String, ApiEnhancedModule> apiEnhancedModuleByName')
  if (listStart === -1 || mapStart === -1 || mapStart <= listStart) {
    throw new Error(`Cannot parse generated manifest: ${generatedManifestPath}`)
  }

  const listSource = source.slice(listStart, mapStart)
  return [...listSource.matchAll(/ApiEnhancedModule\(([\s\S]*?)\),/g)].map((match) => {
    const block = match[1]
    const module = block.match(/module: '([^']+)'/)?.[1]
    if (!module) {
      throw new Error(`Cannot parse module entry: ${block}`)
    }
    return {
      module,
      special: /special: true/.test(block),
    }
  })
}

function loadUpstreamModules() {
  return fs
    .readdirSync(upstreamModuleDir)
    .filter((file) => file.endsWith('.js'))
    .map((file) => file.replace(/\.js$/, ''))
    .sort()
}

function loadOracleFixtures() {
  const source = fs.readFileSync(oracleScriptPath, 'utf8')
  const prefixEnd = source.indexOf('\nconst originalRequire')
  const fixturesStart = source.indexOf('const fixtures = [')
  const fixturesEnd = source.indexOf('\n\nasync function captureFixture', fixturesStart)
  if (prefixEnd === -1 || fixturesStart === -1 || fixturesEnd === -1) {
    throw new Error(`Cannot parse Node oracle fixtures: ${oracleScriptPath}`)
  }

  const fixtureSource = [
    source.slice(0, prefixEnd),
    source.slice(fixturesStart, fixturesEnd),
    'fixtures',
  ].join('\n')
  return vm.runInNewContext(fixtureSource, {
    Buffer,
    JSON,
    __dirname: path.dirname(oracleScriptPath),
    require,
  })
}

function gitOutput(args) {
  try {
    return execFileSync('git', args, {
      cwd: repoRoot,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim()
  } catch (_) {
    return null
  }
}

function sorted(values) {
  return [...values].sort()
}

function isRecord(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value)
}

function stableStringify(value) {
  if (Array.isArray(value)) {
    return `[${value.map((item) => stableStringify(item)).join(',')}]`
  }
  if (value && typeof value === 'object') {
    return `{${Object.keys(value)
      .sort()
      .map((key) => `${JSON.stringify(key)}:${stableStringify(value[key])}`)
      .join(',')}}`
  }
  return JSON.stringify(value)
}

function duplicateFixtures(fixtures) {
  if (!Array.isArray(fixtures)) {
    return []
  }
  const seen = new Set()
  const duplicate = new Set()
  for (const fixture of fixtures) {
    if (!isRecord(fixture)) {
      continue
    }
    const signature = stableStringify({
      allowNoRequest: fixture.allowNoRequest,
      captureRequests: fixture.captureRequests,
      fixedNow: fixture.fixedNow,
      fixedRandomDigits: fixture.fixedRandomDigits,
      module: fixture.module,
      query: fixture.query,
      responses: fixture.responses,
    })
    if (seen.has(signature)) {
      duplicate.add(fixture.module)
    }
    seen.add(signature)
  }
  return sorted(duplicate)
}

function validateOracleFixtures(fixtures) {
  if (!Array.isArray(fixtures)) {
    return [
      {
        index: -1,
        module: '<fixtures>',
        reason: 'Node oracle fixtures must be an array.',
      },
    ]
  }

  const fixtureKeys = new Set([
    'allowNoRequest',
    'captureRequests',
    'fixedNow',
    'fixedRandomDigits',
    'module',
    'query',
    'responses',
  ])
  const responseKeys = new Set(['body', 'cookie', 'reject', 'status'])
  const invalid = []

  function push(index, module, reason) {
    invalid.push({
      index,
      module: typeof module === 'string' && module.length > 0 ? module : `<fixture:${index}>`,
      reason,
    })
  }

  fixtures.forEach((fixture, index) => {
    if (!isRecord(fixture)) {
      push(index, null, 'Node oracle fixture must be an object.')
      return
    }

    const unknownKeys = Object.keys(fixture).filter((key) => !fixtureKeys.has(key)).sort()
    if (unknownKeys.length > 0) {
      push(index, fixture.module, `Node oracle fixture has unknown keys: ${unknownKeys.join(', ')}.`)
    }
    if (typeof fixture.module !== 'string' || fixture.module.trim().length === 0) {
      push(index, fixture.module, 'Node oracle fixture module must be a non-empty string.')
    }
    if (!isRecord(fixture.query)) {
      push(index, fixture.module, 'Node oracle fixture query must be an object.')
    }
    if ('allowNoRequest' in fixture && typeof fixture.allowNoRequest !== 'boolean') {
      push(index, fixture.module, 'Node oracle fixture allowNoRequest must be a boolean.')
    }
    if ('captureRequests' in fixture && typeof fixture.captureRequests !== 'boolean') {
      push(index, fixture.module, 'Node oracle fixture captureRequests must be a boolean.')
    }
    if ('fixedNow' in fixture && typeof fixture.fixedNow !== 'number') {
      push(index, fixture.module, 'Node oracle fixture fixedNow must be a number.')
    }
    if ('fixedRandomDigits' in fixture && typeof fixture.fixedRandomDigits !== 'string') {
      push(index, fixture.module, 'Node oracle fixture fixedRandomDigits must be a string.')
    }
    if ('responses' in fixture) {
      if (!Array.isArray(fixture.responses)) {
        push(index, fixture.module, 'Node oracle fixture responses must be an array.')
      } else {
        fixture.responses.forEach((response, responseIndex) => {
          if (!isRecord(response)) {
            push(index, fixture.module, `Node oracle response ${responseIndex} must be an object.`)
            return
          }
          const unknownResponseKeys = Object.keys(response).filter((key) => !responseKeys.has(key)).sort()
          if (unknownResponseKeys.length > 0) {
            push(
              index,
              fixture.module,
              `Node oracle response ${responseIndex} has unknown keys: ${unknownResponseKeys.join(', ')}.`,
            )
          }
          if ('reject' in response && typeof response.reject !== 'boolean') {
            push(index, fixture.module, `Node oracle response ${responseIndex} reject must be a boolean.`)
          }
          if ('status' in response && typeof response.status !== 'number') {
            push(index, fixture.module, `Node oracle response ${responseIndex} status must be a number.`)
          }
          if ('body' in response && !isRecord(response.body)) {
            push(index, fixture.module, `Node oracle response ${responseIndex} body must be an object.`)
          }
          if ('cookie' in response && !Array.isArray(response.cookie)) {
            push(index, fixture.module, `Node oracle response ${responseIndex} cookie must be an array.`)
          }
        })
      }
    }
  })

  return invalid
}

function setFrom(value) {
  if (!Array.isArray(value)) {
    return new Set()
  }
  return new Set(value.map((item) => item.toString()))
}

function sortedObject(value) {
  return Object.fromEntries(Object.keys(value || {}).sort().map((key) => [key, value[key]]))
}

const upstreamPackage = readJson(upstreamPackagePath)
const coverage = readJson(specialCoveragePath)
const upstreamModules = loadUpstreamModules()
const entries = loadManifestEntries()
const oracleFixtures = loadOracleFixtures()
const oracleFixtureList = Array.isArray(oracleFixtures) ? oracleFixtures : []
const oracleModuleList = oracleFixtureList
  .filter((fixture) => isRecord(fixture))
  .map((fixture) => fixture.module)
  .filter((module) => typeof module === 'string')
const oracleModules = new Set(oracleModuleList)
const manifestModules = entries.map((entry) => entry.module)
const upstreamModuleSet = new Set(upstreamModules)
const manifestModuleSet = new Set(manifestModules)
const normalModules = entries.filter((entry) => !entry.special).map((entry) => entry.module)
const specialModules = entries.filter((entry) => entry.special).map((entry) => entry.module)
const specialSet = new Set(specialModules)
const nodeOracleSpecial = setFrom(coverage.nodeOracle)
const dartBehaviorSpecial = setFrom(coverage.dartBehavior)
const limitedSpecial = new Set(Object.keys(coverage.limited || {}))
const categorizedSpecial = new Set([...nodeOracleSpecial, ...dartBehaviorSpecial, ...limitedSpecial])
const submoduleStatus = gitOutput(['-C', upstreamRepoPath, 'status', '--porcelain']) || ''
const manifestMissingUpstreamModules = sorted(upstreamModules.filter((module) => !manifestModuleSet.has(module)))
const manifestUnknownUpstreamModules = sorted(manifestModules.filter((module) => !upstreamModuleSet.has(module)))
const oracleInvalidFixtures = validateOracleFixtures(oracleFixtures)
const oracleDuplicateFixtures = duplicateFixtures(oracleFixtureList)
const oracleUnknownModules = sorted([...oracleModules].filter((module) => !manifestModuleSet.has(module)))
const normalMissingOracle = sorted(normalModules.filter((module) => !oracleModules.has(module)))
const specialMissingStatus = sorted(specialModules.filter((module) => !categorizedSpecial.has(module)))
const specialUnknownStatus = sorted([...categorizedSpecial].filter((module) => !specialSet.has(module)))
const specialNodeOracleMissingFixture = sorted([...nodeOracleSpecial].filter((module) => !oracleModules.has(module)))
const specialNonLimitedMissingOracle = sorted(
  specialModules.filter((module) => !limitedSpecial.has(module) && !nodeOracleSpecial.has(module)),
)
const specialLimitedMissingReason = sorted(
  [...limitedSpecial].filter((module) => {
    const reason = coverage.limited[module]
    return typeof reason !== 'string' || reason.trim().length === 0
  }),
)
const specialLimitedReasons = sortedObject(coverage.limited)

function buildSdkDifferences() {
  const differences = []
  for (const [module, reason] of Object.entries(specialLimitedReasons)) {
    differences.push({
      module,
      status: 'limited',
      reason,
    })
  }
  for (const module of normalMissingOracle) {
    differences.push({
      module,
      status: 'missing_node_oracle',
      reason: 'Normal module has no Node oracle fixture.',
    })
  }
  for (const module of oracleUnknownModules) {
    differences.push({
      module,
      status: 'unknown_node_oracle_fixture',
      reason: 'Node oracle fixture references a module that is not in the generated manifest.',
    })
  }
  for (const module of oracleDuplicateFixtures) {
    differences.push({
      module,
      status: 'duplicate_node_oracle_fixture',
      reason: 'Node oracle fixture defines the same scenario more than once.',
    })
  }
  for (const fixture of oracleInvalidFixtures) {
    differences.push({
      module: fixture.module,
      status: 'invalid_node_oracle_fixture',
      reason: fixture.reason,
    })
  }
  for (const module of specialMissingStatus) {
    differences.push({
      module,
      status: 'missing_special_status',
      reason: 'Special module is not categorized as Node oracle, Dart behavior, or limited.',
    })
  }
  for (const module of specialNodeOracleMissingFixture) {
    differences.push({
      module,
      status: 'missing_special_oracle_fixture',
      reason: 'Special module is marked as Node oracle covered but has no fixture.',
    })
  }
  for (const module of specialNonLimitedMissingOracle) {
    differences.push({
      module,
      status: 'missing_special_oracle_or_limit',
      reason: 'Special module is not limited and has no Node oracle fixture.',
    })
  }
  for (const module of specialLimitedMissingReason) {
    differences.push({
      module,
      status: 'missing_limited_reason',
      reason: 'Limited special module must explain why it cannot be fully mirrored.',
    })
  }
  return differences.sort((left, right) => `${left.module}:${left.status}`.localeCompare(`${right.module}:${right.status}`))
}

const report = {
  upstreamVersion: upstreamPackage.version,
  upstreamSubmodulePath: path.relative(repoRoot, upstreamRepoPath).replace(/\\/g, '/'),
  upstreamCommit: gitOutput(['-C', upstreamRepoPath, 'rev-parse', 'HEAD']),
  upstreamDirty: submoduleStatus.length > 0,
  upstreamModuleFileCount: upstreamModules.length,
  moduleCount: entries.length,
  normalModuleCount: normalModules.length,
  specialModuleCount: specialModules.length,
  nodeOracleScenarioCount: oracleFixtureList.length,
  nodeOracleFixtureCount: oracleModules.size,
  manifestMissingUpstreamModules,
  manifestUnknownUpstreamModules,
  oracleInvalidFixtures,
  oracleDuplicateFixtures,
  oracleUnknownModules,
  normalMissingOracle,
  specialMissingStatus,
  specialUnknownStatus,
  specialNodeOracleMissingFixture,
  specialNonLimitedMissingOracle,
  specialLimitedMissingReason,
  specialNodeOracle: sorted(nodeOracleSpecial),
  specialDartBehavior: sorted(dartBehaviorSpecial),
  specialLimited: sorted(limitedSpecial),
  specialLimitedReasons,
  sdkDifferences: buildSdkDifferences(),
}

const hasFailure =
  !report.upstreamCommit ||
  report.upstreamDirty ||
  report.manifestMissingUpstreamModules.length > 0 ||
  report.manifestUnknownUpstreamModules.length > 0 ||
  report.oracleInvalidFixtures.length > 0 ||
  report.oracleDuplicateFixtures.length > 0 ||
  report.oracleUnknownModules.length > 0 ||
  report.normalMissingOracle.length > 0 ||
  report.specialMissingStatus.length > 0 ||
  report.specialUnknownStatus.length > 0 ||
  report.specialNodeOracleMissingFixture.length > 0 ||
  report.specialNonLimitedMissingOracle.length > 0 ||
  report.specialLimitedMissingReason.length > 0

if (jsonOutput) {
  console.log(JSON.stringify(report, null, 2))
} else {
  console.log('api-enhanced coverage report')
  console.log(`upstream version: ${report.upstreamVersion}`)
  console.log(`upstream submodule: ${report.upstreamSubmodulePath}`)
  console.log(`upstream commit: ${report.upstreamCommit || 'unknown'}`)
  console.log(`upstream dirty: ${report.upstreamDirty}`)
  console.log(
    `modules: ${report.moduleCount} (upstream files ${report.upstreamModuleFileCount}, normal ${report.normalModuleCount}, special ${report.specialModuleCount})`,
  )
  console.log(`manifest missing upstream modules: ${report.manifestMissingUpstreamModules.length}`)
  console.log(`manifest unknown upstream modules: ${report.manifestUnknownUpstreamModules.length}`)
  console.log(`node oracle scenarios: ${report.nodeOracleScenarioCount}`)
  console.log(`node oracle fixtures: ${report.nodeOracleFixtureCount}`)
  console.log(`node oracle invalid fixtures: ${report.oracleInvalidFixtures.length}`)
  console.log(`node oracle duplicate fixtures: ${report.oracleDuplicateFixtures.length}`)
  console.log(`node oracle unknown modules: ${report.oracleUnknownModules.length}`)
  console.log(`normal modules missing oracle: ${report.normalMissingOracle.length}`)
  console.log(`special modules missing status: ${report.specialMissingStatus.length}`)
  console.log(`special node-oracle modules missing fixture: ${report.specialNodeOracleMissingFixture.length}`)
  console.log(`special non-limited modules missing oracle: ${report.specialNonLimitedMissingOracle.length}`)
  console.log(`special limited modules missing reason: ${report.specialLimitedMissingReason.length}`)
  console.log(`special status unknown modules: ${report.specialUnknownStatus.length}`)
  console.log(`special node oracle: ${report.specialNodeOracle.join(', ')}`)
  console.log(`special dart behavior: ${report.specialDartBehavior.join(', ')}`)
  console.log(`special limited: ${report.specialLimited.join(', ')}`)
  console.log(`SDK differences: ${report.sdkDifferences.length}`)
  console.log('special limited reasons:')
  for (const [module, reason] of Object.entries(report.specialLimitedReasons)) {
    console.log(`- ${module}: ${reason}`)
  }

  if (hasFailure) {
    console.error('\ncoverage report failed; run with --json for machine-readable details')
  }
}

process.exit(hasFailure ? 1 : 0)
