#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
const os = require('os')
const { spawnSync } = require('child_process')

const repoRoot = path.resolve(__dirname, '../../..')
const upstreamDir = path.join(repoRoot, 'third_party/api-enhanced/module')
const packageDir = path.resolve(__dirname, '..')
const generatedDir = path.join(packageDir, 'lib/src/generated')
const rawDir = path.join(packageDir, 'lib/src/endpoints/raw')

const specialModules = new Set([
  'api',
  'eapi_decrypt',
  'decrypt',
  'avatar_upload',
  'playlist_cover_update',
  'cloud',
  'cloud_upload_token',
  'cloud_upload_complete',
  'voice_upload',
  'inner_version',
  'login_qr_create',
  'related_playlist',
  'song_url_match',
  'song_url_ncmget',
  'audio_match',
  'register_anonimous',
  'register_xeapikey',
  'song_url_v1',
  'vip_sign_history',
  'vip_tasks_v1',
])

const supportedCrypto = new Set(['', 'weapi', 'eapi', 'linuxapi', 'api', 'query', 'xeapi'])

function camel(name) {
  return name.replace(/_([a-z0-9])/g, (_, c) => c.toUpperCase())
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

function writeIfChanged(filePath, source) {
  if (fs.existsSync(filePath) && fs.readFileSync(filePath, 'utf8') === source) {
    return false
  }
  fs.writeFileSync(filePath, source)
  return true
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
    special: specialModules.has(module) || pathTemplate === '' || !supportedCrypto.has(crypto),
  }
}

const entries = fs
  .readdirSync(upstreamDir)
  .filter((file) => file.endsWith('.js'))
  .sort()
  .map(moduleEntry)

fs.mkdirSync(generatedDir, { recursive: true })
fs.mkdirSync(rawDir, { recursive: true })

let modules = `// GENERATED CODE - DO NOT MODIFY BY HAND.\n// ignore_for_file: public_member_api_docs\n// Generated from third_party/api-enhanced/module/*.js.\n\nimport 'api_enhanced_module.dart';\n\nconst List<ApiEnhancedModule> apiEnhancedModules = [\n`
for (const entry of entries) {
  modules += `  ApiEnhancedModule(module: '${esc(entry.module)}', methodName: '${esc(entry.methodName)}', pathTemplate: '${esc(entry.pathTemplate)}', crypto: '${esc(entry.crypto)}', httpMethod: '${entry.httpMethod}', special: ${entry.special}),\n`
}
modules += `];\n\nconst Map<String, ApiEnhancedModule> apiEnhancedModuleByName = {\n`
for (const entry of entries) {
  modules += `  '${esc(entry.module)}': ApiEnhancedModule(module: '${esc(entry.module)}', methodName: '${esc(entry.methodName)}', pathTemplate: '${esc(entry.pathTemplate)}', crypto: '${esc(entry.crypto)}', httpMethod: '${entry.httpMethod}', special: ${entry.special}),\n`
}
modules += `};\n`
writeIfChanged(
  path.join(generatedDir, 'api_enhanced_modules.g.dart'),
  formatDart('api_enhanced_modules.g.dart', modules),
)

let methods = `// GENERATED CODE - DO NOT MODIFY BY HAND.\n// ignore_for_file: public_member_api_docs\n// Convenience methods for api-enhanced modules.\n\npart of 'api_enhanced_raw.dart';\n\n/// Generated convenience methods for every upstream api-enhanced module.\nextension ApiEnhancedRawConvenience on ApiEnhancedRaw {\n`
for (const entry of entries) {
  methods += `  /// Raw api-enhanced module \`${entry.module}\`.\n  Future<dynamic> ${entry.methodName}(Map<String, dynamic> query) => requestModule('${esc(entry.module)}', query);\n\n`
}
methods += `}\n`
writeIfChanged(
  path.join(rawDir, 'api_enhanced_raw_methods.g.dart'),
  formatDart('api_enhanced_raw_methods.g.dart', methods),
)

console.log(`Generated ${entries.length} api-enhanced module entries.`)
