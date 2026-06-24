#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
const os = require('os')
const { spawnSync } = require('child_process')

validateArgs(process.argv.slice(2), {
  flags: new Set(['--check']),
  pathPrefixes: ['--generated-dir=', '--raw-dir=', '--special-coverage='],
})

const repoRoot = path.resolve(__dirname, '../../..')
const upstreamRepoPath = path.join(repoRoot, 'third_party/api-enhanced')
const upstreamDir = path.join(upstreamRepoPath, 'module')
const upstreamPackagePath = path.join(upstreamRepoPath, 'package.json')
const packageDir = path.resolve(__dirname, '..')
const generatedDir = resolvePathArg(
  '--generated-dir=',
  path.join(packageDir, 'lib/src/generated'),
)
const rawDir = resolvePathArg(
  '--raw-dir=',
  path.join(packageDir, 'lib/src/endpoints/raw'),
)
const specialCoveragePath = resolvePathArg(
  '--special-coverage=',
  path.join(__dirname, 'api_enhanced_special_coverage.json'),
)
const checkMode = process.argv.includes('--check')
const staleGeneratedFiles = []
const manualSpecialModules = loadManualSpecialModules(specialCoveragePath)

const supportedCrypto = new Set(['', 'weapi', 'eapi', 'linuxapi', 'api', 'query', 'xeapi'])

function validateArgs(args, { flags, pathPrefixes }) {
  for (const arg of args) {
    if (flags.has(arg)) {
      continue
    }
    const pathPrefix = pathPrefixes.find((prefix) => arg.startsWith(prefix))
    if (pathPrefix) {
      if (arg.slice(pathPrefix.length).trim().length === 0) {
        console.error(`Option ${pathPrefix.slice(0, -1)} requires a non-empty path.`)
        process.exit(1)
      }
      continue
    }
    console.error(`Unknown argument: ${arg}`)
    process.exit(1)
  }
}

function resolvePathArg(prefix, fallback) {
  const arg = process.argv.find((value) => value.startsWith(prefix))
  if (!arg) {
    return fallback
  }
  return path.resolve(repoRoot, arg.slice(prefix.length))
}

function isRecord(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value)
}

function loadManualSpecialModules(filePath) {
  const coverage = JSON.parse(fs.readFileSync(filePath, 'utf8'))
  if (!isRecord(coverage)) {
    throw new Error(`Special coverage must be an object: ${filePath}`)
  }

  const modules = new Set()
  function addStringArray(key) {
    if (!Array.isArray(coverage[key])) {
      throw new Error(`Special coverage ${key} must be an array: ${filePath}`)
    }
    for (const item of coverage[key]) {
      if (typeof item !== 'string' || item.trim().length === 0) {
        throw new Error(`Special coverage ${key} entries must be non-empty strings: ${filePath}`)
      }
      modules.add(item.trim())
    }
  }

  addStringArray('nodeOracle')
  addStringArray('dartBehavior')
  if (!isRecord(coverage.limited)) {
    throw new Error(`Special coverage limited must be an object: ${filePath}`)
  }
  for (const module of Object.keys(coverage.limited)) {
    if (module.trim().length === 0) {
      throw new Error(`Special coverage limited module keys must be non-empty strings: ${filePath}`)
    }
    modules.add(module.trim())
  }
  return modules
}

function camel(name) {
  return name.replace(/_([a-z0-9])/g, (_, c) => c.toUpperCase())
}

function upperFirst(name) {
  return name.length === 0 ? name : `${name[0].toUpperCase()}${name.slice(1)}`
}

function rawAliasName(methodName) {
  return `raw${upperFirst(methodName)}`
}

function esc(value) {
  return value
    .replace(/\\/g, '\\\\')
    .replace(/\$/g, '\\$')
    .replace(/'/g, "\\'")
    .replace(/\r?\n/g, '\\n')
}

function formatDart(fileName, source) {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'api-enhanced-'))
  const tempPath = path.join(tempDir, fileName)
  fs.writeFileSync(tempPath, source)
  const format = spawnSync('dart', ['format', tempPath], {
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
  })
  if (format.status !== 0) {
    process.stderr.write(format.stdout || '')
    process.stderr.write(format.stderr || '')
    fs.rmSync(tempDir, { recursive: true, force: true })
    process.exit(format.status || 1)
  }
  const formatted = fs.readFileSync(tempPath, 'utf8')
  fs.rmSync(tempDir, { recursive: true, force: true })
  return formatted
}

function writeGeneratedFile(filePath, source) {
  if (fs.existsSync(filePath) && fs.readFileSync(filePath, 'utf8') === source) {
    return false
  }
  if (checkMode) {
    staleGeneratedFiles.push(path.relative(repoRoot, filePath))
    return true
  }
  fs.writeFileSync(filePath, source)
  return true
}

function gitOutput(args) {
  const result = spawnSync('git', args, {
    cwd: repoRoot,
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'pipe'],
  })
  if (result.status !== 0) {
    process.stderr.write(result.stdout || '')
    process.stderr.write(result.stderr || '')
    process.exit(result.status || 1)
  }
  return result.stdout.trim()
}

function moduleEntry(fileName) {
  const module = fileName.replace(/\.js$/, '')
  const source = fs.readFileSync(path.join(upstreamDir, fileName), 'utf8')
  const requestPaths = [
    ...source.matchAll(/request\(\s*`([^`]+)`|request\(\s*['"]([^'"]+)/g),
  ].map((match) => match[1] || match[2])
  const cryptoMatch = source.match(/createOption\(\s*query\s*,\s*['"]([^'"]+)['"]/)
  const pathTemplate = requestPaths[0] || ''
  const crypto = module === 'api' ? 'query' : cryptoMatch ? cryptoMatch[1] : 'eapi'
  return {
    module,
    methodName: camel(module),
    pathTemplate,
    crypto,
    httpMethod: /method\s*:\s*['"]GET['"]/i.test(source) || /method\s*=\s*['"]GET['"]/i.test(source) ? 'GET' : 'POST',
    special: manualSpecialModules.has(module) || pathTemplate === '' || !supportedCrypto.has(crypto),
  }
}

const entries = fs
  .readdirSync(upstreamDir)
  .filter((file) => file.endsWith('.js'))
  .sort()
  .map(moduleEntry)
const upstreamVersion = JSON.parse(fs.readFileSync(upstreamPackagePath, 'utf8')).version
const upstreamCommit = gitOutput(['-C', upstreamRepoPath, 'rev-parse', 'HEAD'])

fs.mkdirSync(generatedDir, { recursive: true })
fs.mkdirSync(rawDir, { recursive: true })

let modules = `// GENERATED CODE - DO NOT MODIFY BY HAND.\n// ignore_for_file: public_member_api_docs\n// Generated from third_party/api-enhanced/module/*.js.\n\nimport 'api_enhanced_module.dart';\n\nconst String apiEnhancedUpstreamVersion = '${esc(upstreamVersion)}';\nconst String apiEnhancedUpstreamCommit = '${esc(upstreamCommit)}';\n\nconst List<ApiEnhancedModule> apiEnhancedModules = [\n`
for (const entry of entries) {
  modules += `  ApiEnhancedModule(module: '${esc(entry.module)}', methodName: '${esc(entry.methodName)}', pathTemplate: '${esc(entry.pathTemplate)}', crypto: '${esc(entry.crypto)}', httpMethod: '${entry.httpMethod}', special: ${entry.special}),\n`
}
modules += `];\n\nconst Map<String, ApiEnhancedModule> apiEnhancedModuleByName = {\n`
for (const entry of entries) {
  modules += `  '${esc(entry.module)}': ApiEnhancedModule(module: '${esc(entry.module)}', methodName: '${esc(entry.methodName)}', pathTemplate: '${esc(entry.pathTemplate)}', crypto: '${esc(entry.crypto)}', httpMethod: '${entry.httpMethod}', special: ${entry.special}),\n`
}
modules += `};\n`
writeGeneratedFile(
  path.join(generatedDir, 'api_enhanced_modules.g.dart'),
  formatDart('api_enhanced_modules.g.dart', modules),
)

let methods = `// GENERATED CODE - DO NOT MODIFY BY HAND.\n// ignore_for_file: public_member_api_docs\n// Convenience methods for api-enhanced modules.\n\npart of 'api_enhanced_raw.dart';\n\n/// Generated convenience methods for every upstream api-enhanced module.\nextension ApiEnhancedRawConvenience on ApiEnhancedRaw {\n`
for (const entry of entries) {
  methods += `  /// Raw api-enhanced module \`${entry.module}\`.\n  Future<dynamic> ${entry.methodName}(Map<String, dynamic> query) => requestModule('${esc(entry.module)}', query);\n\n`
  methods += `  /// Collision-safe raw api-enhanced module \`${entry.module}\`.\n  Future<dynamic> ${rawAliasName(entry.methodName)}(Map<String, dynamic> query) => requestModule('${esc(entry.module)}', query);\n\n`
}
methods += `}\n`
writeGeneratedFile(
  path.join(rawDir, 'api_enhanced_raw_methods.g.dart'),
  formatDart('api_enhanced_raw_methods.g.dart', methods),
)

if (checkMode) {
  if (staleGeneratedFiles.length > 0) {
    console.error('Generated api-enhanced files are stale:')
    for (const filePath of staleGeneratedFiles) {
      console.error(`- ${filePath}`)
    }
    console.error('Run: node packages/netease_music_api/tool/generate_api_enhanced_modules.js')
    process.exit(1)
  }
  console.log(`Generated api-enhanced files are up to date (${entries.length} module entries).`)
} else {
  console.log(`Generated ${entries.length} api-enhanced module entries.`)
}
