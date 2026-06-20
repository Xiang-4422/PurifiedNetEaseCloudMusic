#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
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

function loadOracleModules() {
  const source = fs.readFileSync(oracleScriptPath, 'utf8')
  return new Set([...source.matchAll(/module: '([^']+)'/g)].map((match) => match[1]))
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
const oracleModules = loadOracleModules()
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

const report = {
  upstreamVersion: upstreamPackage.version,
  upstreamSubmodulePath: path.relative(repoRoot, upstreamRepoPath).replace(/\\/g, '/'),
  upstreamCommit: gitOutput(['-C', upstreamRepoPath, 'rev-parse', 'HEAD']),
  upstreamDirty: submoduleStatus.length > 0,
  upstreamModuleFileCount: upstreamModules.length,
  moduleCount: entries.length,
  normalModuleCount: normalModules.length,
  specialModuleCount: specialModules.length,
  nodeOracleFixtureCount: oracleModules.size,
  manifestMissingUpstreamModules: sorted(upstreamModules.filter((module) => !manifestModuleSet.has(module))),
  manifestUnknownUpstreamModules: sorted(manifestModules.filter((module) => !upstreamModuleSet.has(module))),
  normalMissingOracle: sorted(normalModules.filter((module) => !oracleModules.has(module))),
  specialMissingStatus: sorted(specialModules.filter((module) => !categorizedSpecial.has(module))),
  specialUnknownStatus: sorted([...categorizedSpecial].filter((module) => !specialSet.has(module))),
  specialNodeOracleMissingFixture: sorted([...nodeOracleSpecial].filter((module) => !oracleModules.has(module))),
  specialNonLimitedMissingOracle: sorted(
    specialModules.filter((module) => !limitedSpecial.has(module) && !nodeOracleSpecial.has(module)),
  ),
  specialLimitedMissingReason: sorted(
    [...limitedSpecial].filter((module) => {
      const reason = coverage.limited[module]
      return typeof reason !== 'string' || reason.trim().length === 0
    }),
  ),
  specialNodeOracle: sorted(nodeOracleSpecial),
  specialDartBehavior: sorted(dartBehaviorSpecial),
  specialLimited: sorted(limitedSpecial),
  specialLimitedReasons: sortedObject(coverage.limited),
}

const hasFailure =
  !report.upstreamCommit ||
  report.upstreamDirty ||
  report.manifestMissingUpstreamModules.length > 0 ||
  report.manifestUnknownUpstreamModules.length > 0 ||
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
  console.log(`node oracle fixtures: ${report.nodeOracleFixtureCount}`)
  console.log(`normal modules missing oracle: ${report.normalMissingOracle.length}`)
  console.log(`special modules missing status: ${report.specialMissingStatus.length}`)
  console.log(`special node-oracle modules missing fixture: ${report.specialNodeOracleMissingFixture.length}`)
  console.log(`special non-limited modules missing oracle: ${report.specialNonLimitedMissingOracle.length}`)
  console.log(`special limited modules missing reason: ${report.specialLimitedMissingReason.length}`)
  console.log(`special status unknown modules: ${report.specialUnknownStatus.length}`)
  console.log(`special node oracle: ${report.specialNodeOracle.join(', ')}`)
  console.log(`special dart behavior: ${report.specialDartBehavior.join(', ')}`)
  console.log(`special limited: ${report.specialLimited.join(', ')}`)
  console.log('special limited reasons:')
  for (const [module, reason] of Object.entries(report.specialLimitedReasons)) {
    console.log(`- ${module}: ${reason}`)
  }

  if (hasFailure) {
    console.error('\ncoverage report failed; run with --json for machine-readable details')
  }
}

process.exit(hasFailure ? 1 : 0)
