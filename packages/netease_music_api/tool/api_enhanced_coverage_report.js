#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
const vm = require('vm')
const { execFileSync } = require('child_process')

const repoRoot = path.resolve(__dirname, '../../..')
const upstreamRepoPath = path.join(repoRoot, 'third_party/api-enhanced')
const upstreamPackagePath = path.join(upstreamRepoPath, 'package.json')
const upstreamModuleDir = path.join(upstreamRepoPath, 'module')
const generatedManifestArg = process.argv.find((arg) => arg.startsWith('--generated-manifest='))
const generatedManifestPath = generatedManifestArg
  ? path.resolve(repoRoot, generatedManifestArg.slice('--generated-manifest='.length))
  : path.join(repoRoot, 'packages/netease_music_api/lib/src/generated/api_enhanced_modules.g.dart')
const oracleScriptPath = path.join(repoRoot, 'packages/netease_music_api/tool/api_enhanced_node_oracle.js')
const specialCoverageArg = process.argv.find((arg) => arg.startsWith('--special-coverage='))
const specialCoveragePath = specialCoverageArg
  ? path.resolve(repoRoot, specialCoverageArg.slice('--special-coverage='.length))
  : path.join(repoRoot, 'packages/netease_music_api/tool/api_enhanced_special_coverage.json')
const jsonOutput = process.argv.includes('--json')

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'))
}

function parseConstString(source, name) {
  return new RegExp(`const\\s+String\\s+${name}\\s*=\\s*'([^']*)';`).exec(source)?.[1] || null
}

function loadManifest() {
  const source = fs.readFileSync(generatedManifestPath, 'utf8')
  const listStart = source.indexOf('const List<ApiEnhancedModule> apiEnhancedModules')
  const mapStart = source.indexOf('const Map<String, ApiEnhancedModule> apiEnhancedModuleByName')
  if (listStart === -1 || mapStart === -1 || mapStart <= listStart) {
    throw new Error(`Cannot parse generated manifest: ${generatedManifestPath}`)
  }

  const listSource = source.slice(listStart, mapStart)
  return {
    upstreamVersion: parseConstString(source, 'apiEnhancedUpstreamVersion'),
    upstreamCommit: parseConstString(source, 'apiEnhancedUpstreamCommit'),
    entries: [...listSource.matchAll(/ApiEnhancedModule\(([\s\S]*?)\),/g)].map((match) => {
      const block = match[1]
      const module = block.match(/module: '([^']+)'/)?.[1]
      const methodName = block.match(/methodName: '([^']+)'/)?.[1]
      if (!module) {
        throw new Error(`Cannot parse module entry: ${block}`)
      }
      if (!methodName) {
        throw new Error(`Cannot parse methodName entry: ${block}`)
      }
      return {
        module,
        methodName,
        special: /special: true/.test(block),
      }
    }),
  }
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

function duplicateValues(values) {
  const seen = new Set()
  const duplicate = new Set()
  for (const value of values) {
    if (seen.has(value)) {
      duplicate.add(value)
    }
    seen.add(value)
  }
  return sorted(duplicate)
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

function stringSetFrom(value) {
  if (!Array.isArray(value)) {
    return new Set()
  }
  return new Set(
    value
      .filter((item) => typeof item === 'string')
      .map((item) => item.trim())
      .filter((item) => item.length > 0),
  )
}

function sortedObject(value) {
  if (!isRecord(value)) {
    return {}
  }
  return Object.fromEntries(Object.keys(value).sort().map((key) => [key, value[key]]))
}

function validateSpecialCoverageStringArray(coverage, key) {
  const value = coverage[key]
  if (!Array.isArray(value)) {
    return [
      {
        field: key,
        reason: `Special coverage ${key} must be an array.`,
      },
    ]
  }

  const invalid = []
  value.forEach((item, index) => {
    const field = `${key}[${index}]`
    if (typeof item !== 'string') {
      invalid.push({
        field,
        reason: `Special coverage ${key} entries must be strings.`,
      })
      return
    }
    if (item.trim().length === 0) {
      invalid.push({
        field,
        reason: `Special coverage ${key} entries must be non-empty strings.`,
      })
      return
    }
    if (item !== item.trim()) {
      invalid.push({
        field,
        reason: `Special coverage ${key} entries must not include surrounding whitespace.`,
      })
    }
  })
  return invalid
}

function validateSpecialCoverage(coverage) {
  if (!isRecord(coverage)) {
    return [
      {
        field: '<root>',
        reason: 'Special coverage must be an object.',
      },
    ]
  }

  const invalid = []
  const allowedKeys = new Set(['dartBehavior', 'limited', 'nodeOracle'])
  const unknownKeys = Object.keys(coverage).filter((key) => !allowedKeys.has(key)).sort()
  for (const key of unknownKeys) {
    invalid.push({
      field: key,
      reason: `Special coverage has unknown top-level key: ${key}.`,
    })
  }
  invalid.push(...validateSpecialCoverageStringArray(coverage, 'nodeOracle'))
  invalid.push(...validateSpecialCoverageStringArray(coverage, 'dartBehavior'))

  if (!isRecord(coverage.limited)) {
    invalid.push({
      field: 'limited',
      reason: 'Special coverage limited must be an object.',
    })
  } else {
    for (const [module, reason] of Object.entries(coverage.limited)) {
      if (module.trim().length === 0) {
        invalid.push({
          field: 'limited',
          reason: 'Special coverage limited module keys must be non-empty strings.',
        })
      } else if (module !== module.trim()) {
        invalid.push({
          field: `limited.${module}`,
          reason: 'Special coverage limited module keys must not include surrounding whitespace.',
        })
      }
      if (typeof reason !== 'string' || reason.trim().length === 0) {
        invalid.push({
          field: `limited.${module}`,
          reason: 'Special coverage limited reasons must be non-empty strings.',
        })
      }
    }
  }
  return invalid
}

function duplicateSpecialCoverageEntries(coverage) {
  if (!isRecord(coverage)) {
    return []
  }

  const duplicates = []
  for (const field of ['nodeOracle', 'dartBehavior']) {
    if (!Array.isArray(coverage[field])) {
      continue
    }
    const entries = coverage[field]
      .filter((item) => typeof item === 'string')
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
    for (const module of duplicateValues(entries)) {
      duplicates.push({
        field,
        module,
      })
    }
  }
  return duplicates.sort((left, right) => `${left.field}:${left.module}`.localeCompare(`${right.field}:${right.module}`))
}

const upstreamPackage = readJson(upstreamPackagePath)
const coverage = readJson(specialCoveragePath)
const specialCoverage = isRecord(coverage) ? coverage : {}
const upstreamModules = loadUpstreamModules()
const manifest = loadManifest()
const entries = manifest.entries
const oracleFixtures = loadOracleFixtures()
const oracleFixtureList = Array.isArray(oracleFixtures) ? oracleFixtures : []
const oracleModuleList = oracleFixtureList
  .filter((fixture) => isRecord(fixture))
  .map((fixture) => fixture.module)
  .filter((module) => typeof module === 'string')
const oracleModules = new Set(oracleModuleList)
const manifestModules = entries.map((entry) => entry.module)
const manifestMethodNames = entries.map((entry) => entry.methodName)
const upstreamModuleSet = new Set(upstreamModules)
const manifestModuleSet = new Set(manifestModules)
const normalModules = entries.filter((entry) => !entry.special).map((entry) => entry.module)
const specialModules = entries.filter((entry) => entry.special).map((entry) => entry.module)
const specialSet = new Set(specialModules)
const nodeOracleSpecial = stringSetFrom(specialCoverage.nodeOracle)
const dartBehaviorSpecial = stringSetFrom(specialCoverage.dartBehavior)
const specialLimitedReasons = sortedObject(specialCoverage.limited)
const runtimeLimitedReasons = sortedObject({
  'runtime:proxy.pac':
    'proxy 支持 HTTP/HTTPS 代理 URL 和基础认证；明确的 PAC 文件或 PAC scheme 暂不支持，Dart client 会显式抛 UnsupportedError。',
  'runtime:source_order':
    'source order 只属于 song_url_v1 的 unblock 解灰路径；Dart SDK 当前未实现 unblockmusic-utils，普通 xeapi 播放 URL 请求会忽略 source。',
})
const limitedSpecial = new Set(Object.keys(specialLimitedReasons))
const categorizedSpecial = new Set([...nodeOracleSpecial, ...dartBehaviorSpecial, ...limitedSpecial])
const upstreamCommit = gitOutput(['-C', upstreamRepoPath, 'rev-parse', 'HEAD'])
const submoduleStatus = gitOutput(['-C', upstreamRepoPath, 'status', '--porcelain']) || ''
const manifestDuplicateModules = duplicateValues(manifestModules)
const manifestDuplicateMethodNames = duplicateValues(manifestMethodNames)
const manifestMissingUpstreamModules = sorted(upstreamModules.filter((module) => !manifestModuleSet.has(module)))
const manifestUnknownUpstreamModules = sorted(manifestModules.filter((module) => !upstreamModuleSet.has(module)))
const manifestUpstreamMismatches = [
  {
    field: 'version',
    manifest: manifest.upstreamVersion,
    upstream: upstreamPackage.version,
  },
  {
    field: 'commit',
    manifest: manifest.upstreamCommit,
    upstream: upstreamCommit,
  },
].filter((item) => item.manifest !== item.upstream)
const specialCoverageInvalidEntries = validateSpecialCoverage(coverage)
const specialCoverageDuplicateEntries = duplicateSpecialCoverageEntries(coverage)
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
    const reason = specialLimitedReasons[module]
    return typeof reason !== 'string' || reason.trim().length === 0
  }),
)
const runtimeSupportedReasons = sortedObject({
  'runtime:FLAC': 'song_url_v1 和下载 URL 请求固定使用 encodeType=flac。',
  'runtime:checkToken': 'checkToken 写入 eapi header 的 X-antiCheatToken。',
  'runtime:cookie': 'cookie 进入 request options，并参与加密请求 header。',
  'runtime:domain': 'domain 覆盖 raw request host。',
  'runtime:e_r': 'e_r 进入 raw request options，并启用加密响应解密。',
  'runtime:proxy.auth': '代理 URL user info 会转为基础认证代理凭据。',
  'runtime:proxy.http': 'HTTP/HTTPS 代理 URL 会映射为 Dart native proxy rule。',
  'runtime:randomCNIP': 'randomCNIP 生成可用国内 IPv4，且 query 显式值优先于 SDK 默认值。',
  'runtime:realIP': 'realIP 写入 X-Real-IP 和 X-Forwarded-For。',
  'runtime:ua': 'ua 映射为原始 User-Agent。',
})
const runtimeSupported = new Set(Object.keys(runtimeSupportedReasons))
const runtimeLimited = new Set(Object.keys(runtimeLimitedReasons))

function buildSdkDifferences() {
  const differences = []
  if (!upstreamCommit) {
    differences.push({
      module: '<upstream_submodule>',
      status: 'missing_upstream_commit',
      reason: 'Cannot read upstream submodule commit.',
      scope: 'upstream_submodule',
    })
  }
  if (submoduleStatus.length > 0) {
    differences.push({
      module: '<upstream_submodule>',
      status: 'dirty_upstream_submodule',
      reason: 'Upstream submodule has uncommitted changes.',
      scope: 'upstream_submodule',
    })
  }
  for (const entry of specialCoverageInvalidEntries) {
    differences.push({
      module: '<special_coverage>',
      status: 'invalid_special_coverage',
      reason: `${entry.field}: ${entry.reason}`,
      scope: 'special_coverage_config',
    })
  }
  for (const entry of specialCoverageDuplicateEntries) {
    differences.push({
      module: entry.module,
      status: 'duplicate_special_coverage_entry',
      reason: `Special coverage ${entry.field} lists this module more than once.`,
      scope: 'special_coverage_config',
    })
  }
  for (const [module, reason] of Object.entries(specialLimitedReasons)) {
    differences.push({
      module,
      status: 'limited',
      reason,
      scope: 'special_module',
    })
  }
  for (const [module, reason] of Object.entries(runtimeLimitedReasons)) {
    differences.push({
      module,
      status: 'limited',
      reason,
      scope: 'runtime_option',
    })
  }
  for (const module of normalMissingOracle) {
    differences.push({
      module,
      status: 'missing_node_oracle',
      reason: 'Normal module has no Node oracle fixture.',
      scope: 'node_oracle',
    })
  }
  for (const module of oracleUnknownModules) {
    differences.push({
      module,
      status: 'unknown_node_oracle_fixture',
      reason: 'Node oracle fixture references a module that is not in the generated manifest.',
      scope: 'node_oracle',
    })
  }
  for (const module of oracleDuplicateFixtures) {
    differences.push({
      module,
      status: 'duplicate_node_oracle_fixture',
      reason: 'Node oracle fixture defines the same scenario more than once.',
      scope: 'node_oracle',
    })
  }
  for (const fixture of oracleInvalidFixtures) {
    differences.push({
      module: fixture.module,
      status: 'invalid_node_oracle_fixture',
      reason: fixture.reason,
      scope: 'node_oracle',
    })
  }
  for (const module of specialMissingStatus) {
    differences.push({
      module,
      status: 'missing_special_status',
      reason: 'Special module is not categorized as Node oracle, Dart behavior, or limited.',
      scope: 'special_module',
    })
  }
  for (const module of specialUnknownStatus) {
    differences.push({
      module,
      status: 'unknown_special_status',
      reason: 'Special coverage config references a module that is not marked as special in the generated manifest.',
      scope: 'special_coverage_config',
    })
  }
  for (const module of specialNodeOracleMissingFixture) {
    differences.push({
      module,
      status: 'missing_special_oracle_fixture',
      reason: 'Special module is marked as Node oracle covered but has no fixture.',
      scope: 'node_oracle',
    })
  }
  for (const module of specialNonLimitedMissingOracle) {
    differences.push({
      module,
      status: 'missing_special_oracle_or_limit',
      reason: 'Special module is not limited and has no Node oracle fixture.',
      scope: 'special_module',
    })
  }
  for (const module of specialLimitedMissingReason) {
    differences.push({
      module,
      status: 'missing_limited_reason',
      reason: 'Limited special module must explain why it cannot be fully mirrored.',
      scope: 'special_module',
    })
  }
  for (const mismatch of manifestUpstreamMismatches) {
    differences.push({
      module: '<generated_manifest>',
      status: `manifest_upstream_${mismatch.field}_mismatch`,
      reason: `Generated manifest ${mismatch.field} ${mismatch.manifest || '<missing>'} does not match upstream ${mismatch.upstream || '<unknown>'}.`,
      scope: 'generated_manifest',
    })
  }
  for (const module of manifestMissingUpstreamModules) {
    differences.push({
      module,
      status: 'missing_upstream_module',
      reason: 'Generated manifest does not include this upstream module.',
      scope: 'generated_manifest',
    })
  }
  for (const module of manifestUnknownUpstreamModules) {
    differences.push({
      module,
      status: 'unknown_upstream_module',
      reason: 'Generated manifest includes a module that is not present in upstream module/*.js.',
      scope: 'generated_manifest',
    })
  }
  for (const module of manifestDuplicateModules) {
    differences.push({
      module,
      status: 'duplicate_manifest_module',
      reason: 'Generated manifest defines the same module more than once.',
      scope: 'generated_manifest',
    })
  }
  for (const methodName of manifestDuplicateMethodNames) {
    differences.push({
      module: '<generated_manifest>',
      status: 'duplicate_manifest_method_name',
      reason: `Generated manifest defines raw method name ${methodName} more than once.`,
      scope: 'generated_manifest',
    })
  }
  return differences.sort((left, right) => `${left.module}:${left.status}`.localeCompare(`${right.module}:${right.status}`))
}

function buildSpecialCoverageStatusByModule() {
  const statusByModule = {}
  for (const module of sorted(specialModules)) {
    const coverage = []
    if (nodeOracleSpecial.has(module)) {
      coverage.push('nodeOracle')
    }
    if (dartBehaviorSpecial.has(module)) {
      coverage.push('dartBehavior')
    }
    if (limitedSpecial.has(module)) {
      coverage.push('limited')
    }
    statusByModule[module] = {
      coverage,
      hasNodeOracleFixture: oracleModules.has(module),
      limitedReason: specialLimitedReasons[module] || null,
    }
  }
  return statusByModule
}

function buildRuntimeOptionStatusByName() {
  const statusByName = {}
  for (const [name, reason] of Object.entries(runtimeSupportedReasons)) {
    statusByName[name] = {
      status: 'supported',
      reason,
    }
  }
  for (const [name, reason] of Object.entries(runtimeLimitedReasons)) {
    statusByName[name] = {
      status: 'limited',
      reason,
    }
  }
  return sortedObject(statusByName)
}

const report = {
  upstreamVersion: upstreamPackage.version,
  upstreamSubmodulePath: path.relative(repoRoot, upstreamRepoPath).replace(/\\/g, '/'),
  upstreamCommit,
  upstreamDirty: submoduleStatus.length > 0,
  manifestUpstreamVersion: manifest.upstreamVersion,
  manifestUpstreamCommit: manifest.upstreamCommit,
  manifestUpstreamMismatches,
  manifestDuplicateModules,
  manifestDuplicateMethodNames,
  specialCoverageInvalidEntries,
  specialCoverageDuplicateEntries,
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
  runtimeSupported: sorted(runtimeSupported),
  runtimeLimited: sorted(runtimeLimited),
  specialCoverageStatusByModule: buildSpecialCoverageStatusByModule(),
  runtimeOptionStatusByName: buildRuntimeOptionStatusByName(),
  specialLimitedReasons,
  runtimeSupportedReasons,
  runtimeLimitedReasons,
  sdkDifferences: buildSdkDifferences(),
}

const hasFailure =
  !report.upstreamCommit ||
  report.upstreamDirty ||
  report.manifestUpstreamMismatches.length > 0 ||
  report.manifestDuplicateModules.length > 0 ||
  report.manifestDuplicateMethodNames.length > 0 ||
  report.specialCoverageInvalidEntries.length > 0 ||
  report.specialCoverageDuplicateEntries.length > 0 ||
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
  console.log(`manifest upstream version: ${report.manifestUpstreamVersion || 'unknown'}`)
  console.log(`manifest upstream commit: ${report.manifestUpstreamCommit || 'unknown'}`)
  console.log(`manifest upstream mismatches: ${report.manifestUpstreamMismatches.length}`)
  console.log(`manifest duplicate modules: ${report.manifestDuplicateModules.length}`)
  console.log(`manifest duplicate method names: ${report.manifestDuplicateMethodNames.length}`)
  console.log(`special coverage invalid entries: ${report.specialCoverageInvalidEntries.length}`)
  console.log(`special coverage duplicate entries: ${report.specialCoverageDuplicateEntries.length}`)
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
  console.log(`runtime supported: ${report.runtimeSupported.join(', ')}`)
  console.log(`runtime limited: ${report.runtimeLimited.join(', ')}`)
  console.log(`special coverage status entries: ${Object.keys(report.specialCoverageStatusByModule).length}`)
  console.log(`runtime option status entries: ${Object.keys(report.runtimeOptionStatusByName).length}`)
  console.log(`SDK differences: ${report.sdkDifferences.length}`)
  console.log('special limited reasons:')
  for (const [module, reason] of Object.entries(report.specialLimitedReasons)) {
    console.log(`- ${module}: ${reason}`)
  }
  console.log('runtime supported reasons:')
  for (const [module, reason] of Object.entries(report.runtimeSupportedReasons)) {
    console.log(`- ${module}: ${reason}`)
  }
  console.log('runtime limited reasons:')
  for (const [module, reason] of Object.entries(report.runtimeLimitedReasons)) {
    console.log(`- ${module}: ${reason}`)
  }

  if (hasFailure) {
    console.error('\ncoverage report failed; run with --json for machine-readable details')
  }
}

process.exit(hasFailure ? 1 : 0)
