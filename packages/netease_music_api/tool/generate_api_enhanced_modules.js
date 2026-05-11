#!/usr/bin/env node

const fs = require('fs')
const path = require('path')

const repoRoot = path.resolve(__dirname, '../../..')
const upstreamDir = path.join(repoRoot, 'third_party/api-enhanced/module')
const packageDir = path.resolve(__dirname, '..')
const generatedDir = path.join(packageDir, 'lib/src/generated')
const rawDir = path.join(packageDir, 'lib/src/endpoints/raw')

const specialModules = new Set([
  'api',
  'eapi_decrypt',
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
])

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

function moduleEntry(fileName) {
  const module = fileName.replace(/\.js$/, '')
  const source = fs.readFileSync(path.join(upstreamDir, fileName), 'utf8')
  const requestPaths = [
    ...source.matchAll(/request\(\s*`([^`]+)`|request\(\s*['"]([^'"]+)/g),
  ].map((match) => match[1] || match[2])
  const cryptoMatch = source.match(/createOption\(\s*query\s*,\s*['"]([^'"]+)['"]/)
  return {
    module,
    methodName: camel(module),
    pathTemplate: requestPaths[0] || '',
    crypto: module === 'api' ? 'query' : cryptoMatch ? cryptoMatch[1] : 'eapi',
    httpMethod: /method\s*:\s*['"]GET['"]/i.test(source) || /method\s*=\s*['"]GET['"]/i.test(source) ? 'GET' : 'POST',
    special: specialModules.has(module),
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
fs.writeFileSync(path.join(generatedDir, 'api_enhanced_modules.g.dart'), modules)

let methods = `// GENERATED CODE - DO NOT MODIFY BY HAND.\n// ignore_for_file: public_member_api_docs\n// Convenience methods for api-enhanced modules.\n\npart of 'api_enhanced_raw.dart';\n\n/// Generated convenience methods for every upstream api-enhanced module.\nextension ApiEnhancedRawConvenience on ApiEnhancedRaw {\n`
for (const entry of entries) {
  methods += `  /// Raw api-enhanced module \`${entry.module}\`.\n  Future<dynamic> ${entry.methodName}(Map<String, dynamic> query) => requestModule('${esc(entry.module)}', query);\n\n`
}
methods += `}\n`
fs.writeFileSync(path.join(rawDir, 'api_enhanced_raw_methods.g.dart'), methods)

console.log(`Generated ${entries.length} api-enhanced module entries.`)
