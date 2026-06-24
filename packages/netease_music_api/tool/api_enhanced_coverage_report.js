#!/usr/bin/env node

const fs = require('fs')
const path = require('path')
const vm = require('vm')
const { execFileSync } = require('child_process')

validateArgs(process.argv.slice(2), {
  flags: new Set(['--json', '--markdown']),
  pathPrefixes: [
    '--generated-manifest=',
    '--raw-methods=',
    '--raw-dispatcher=',
    '--public-api=',
    '--public-facade=',
    '--special-coverage=',
    '--write-differences-doc=',
    '--check-differences-doc=',
  ],
})

const repoRoot = path.resolve(__dirname, '../../..')
const upstreamRepoPath = path.join(repoRoot, 'third_party/api-enhanced')
const upstreamPackagePath = path.join(upstreamRepoPath, 'package.json')
const upstreamModuleDir = path.join(upstreamRepoPath, 'module')
const generatedManifestArg = process.argv.find((arg) => arg.startsWith('--generated-manifest='))
const generatedManifestPath = generatedManifestArg
  ? path.resolve(repoRoot, generatedManifestArg.slice('--generated-manifest='.length))
  : path.join(repoRoot, 'packages/netease_music_api/lib/src/generated/api_enhanced_modules.g.dart')
const oracleScriptPath = path.join(repoRoot, 'packages/netease_music_api/tool/api_enhanced_node_oracle.js')
const rawMethodsArg = process.argv.find((arg) => arg.startsWith('--raw-methods='))
const rawMethodsPath = rawMethodsArg
  ? path.resolve(repoRoot, rawMethodsArg.slice('--raw-methods='.length))
  : path.join(repoRoot, 'packages/netease_music_api/lib/src/endpoints/raw/api_enhanced_raw_methods.g.dart')
const rawDispatcherArg = process.argv.find((arg) => arg.startsWith('--raw-dispatcher='))
const rawDispatcherPath = rawDispatcherArg
  ? path.resolve(repoRoot, rawDispatcherArg.slice('--raw-dispatcher='.length))
  : path.join(repoRoot, 'packages/netease_music_api/lib/src/endpoints/raw/api_enhanced_raw.dart')
const publicApiArg = process.argv.find((arg) => arg.startsWith('--public-api='))
const publicApiPath = publicApiArg
  ? path.resolve(repoRoot, publicApiArg.slice('--public-api='.length))
  : path.join(repoRoot, 'packages/netease_music_api/lib/netease_music_api.dart')
const publicFacadeArg = process.argv.find((arg) => arg.startsWith('--public-facade='))
const publicFacadePath = publicFacadeArg
  ? path.resolve(repoRoot, publicFacadeArg.slice('--public-facade='.length))
  : path.join(repoRoot, 'packages/netease_music_api/lib/src/client/netease_api.dart')
const specialCoverageArg = process.argv.find((arg) => arg.startsWith('--special-coverage='))
const specialCoveragePath = specialCoverageArg
  ? path.resolve(repoRoot, specialCoverageArg.slice('--special-coverage='.length))
  : path.join(repoRoot, 'packages/netease_music_api/tool/api_enhanced_special_coverage.json')
const writeDifferencesDocArg = process.argv.find((arg) => arg.startsWith('--write-differences-doc='))
const writeDifferencesDocPath = writeDifferencesDocArg
  ? path.resolve(repoRoot, writeDifferencesDocArg.slice('--write-differences-doc='.length))
  : null
const checkDifferencesDocArg = process.argv.find((arg) => arg.startsWith('--check-differences-doc='))
const checkDifferencesDocPath = checkDifferencesDocArg
  ? path.resolve(repoRoot, checkDifferencesDocArg.slice('--check-differences-doc='.length))
  : null
const jsonOutput = process.argv.includes('--json')
const markdownOutput = process.argv.includes('--markdown')
const coverageReportSchemaVersion = 1
const sdkDifferencesDocStart = '<!-- SDK_DIFFERENCES_START -->'
const sdkDifferencesDocEnd = '<!-- SDK_DIFFERENCES_END -->'
const generatedManifestSupportedCrypto = new Set(['weapi', 'eapi', 'linuxapi', 'api', 'xeapi'])
const upstreamManifestSupportedCrypto = new Set(['', 'weapi', 'eapi', 'linuxapi', 'api', 'query', 'xeapi'])
const generatedManifestSupportedHttpMethods = new Set(['GET', 'POST'])
const expectedPublicApiExports = [
  'src/client/netease_api.dart',
  'src/client/netease_bean.dart',
  'src/endpoints/raw/api_enhanced_raw.dart',
]
const expectedTypedFacadeMixins = [
  'ApiDj',
  'ApiEvent',
  'ApiLogin',
  'ApiPlay',
  'ApiSearch',
  'ApiUncategorized',
  'ApiUser',
]
const expectedRawFacadeMixins = ['ApiEnhancedRaw']
const expectedPublicFacadeMixins = sorted([...expectedTypedFacadeMixins, ...expectedRawFacadeMixins])

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

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'))
}

function parseConstString(source, name) {
  return new RegExp(`const\\s+String\\s+${name}\\s*=\\s*'([^']*)';`).exec(source)?.[1] || null
}

function parseDartSingleQuotedString(value) {
  if (typeof value !== 'string') {
    return value
  }
  let result = ''
  for (let index = 0; index < value.length; index += 1) {
    const char = value[index]
    if (char !== '\\' || index + 1 >= value.length) {
      result += char
      continue
    }
    index += 1
    const escaped = value[index]
    switch (escaped) {
      case 'n':
        result += '\n'
        break
      case 'r':
        result += '\r'
        break
      case "'":
        result += "'"
        break
      case '$':
        result += '$'
        break
      case '\\':
        result += '\\'
        break
      default:
        result += escaped
        break
    }
  }
  return result
}

function parseManifestEntry(block, context) {
  const module = parseDartSingleQuotedString(block.match(/module: '((?:\\.|[^'])+)'/)?.[1])
  const methodName = parseDartSingleQuotedString(block.match(/methodName: '((?:\\.|[^'])+)'/)?.[1])
  const pathTemplate = parseDartSingleQuotedString(block.match(/pathTemplate: '((?:\\.|[^'])*)'/)?.[1])
  const crypto = parseDartSingleQuotedString(block.match(/crypto: '((?:\\.|[^'])*)'/)?.[1])
  const httpMethod = parseDartSingleQuotedString(block.match(/httpMethod: '((?:\\.|[^'])+)'/)?.[1])
  if (!module) {
    throw new Error(`Cannot parse module entry from ${context}: ${block}`)
  }
  if (!methodName) {
    throw new Error(`Cannot parse methodName entry from ${context}: ${block}`)
  }
  return {
    module,
    methodName,
    pathTemplate,
    crypto,
    httpMethod,
    special: /special: true/.test(block),
  }
}

function loadManifest() {
  const source = fs.readFileSync(generatedManifestPath, 'utf8')
  const listStart = source.indexOf('const List<ApiEnhancedModule> apiEnhancedModules')
  const mapStart = source.indexOf('const Map<String, ApiEnhancedModule> apiEnhancedModuleByName')
  if (listStart === -1 || mapStart === -1 || mapStart <= listStart) {
    throw new Error(`Cannot parse generated manifest: ${generatedManifestPath}`)
  }

  const listSource = source.slice(listStart, mapStart)
  const mapSource = source.slice(mapStart)
  return {
    upstreamVersion: parseConstString(source, 'apiEnhancedUpstreamVersion'),
    upstreamCommit: parseConstString(source, 'apiEnhancedUpstreamCommit'),
    entries: [...listSource.matchAll(/ApiEnhancedModule\(([\s\S]*?)\),/g)].map((match) => parseManifestEntry(match[1], 'list')),
    mapEntries: [...mapSource.matchAll(/'([^']+)':\s*ApiEnhancedModule\(([\s\S]*?)\),/g)].map((match) => ({
      key: match[1],
      ...parseManifestEntry(match[2], `map.${match[1]}`),
    })),
  }
}

function camel(name) {
  return name.replace(/_([a-z0-9])/g, (_, char) => char.toUpperCase())
}

function manualSpecialModulesFromCoverage(coverage) {
  const modules = new Set([
    ...stringSetFrom(coverage.nodeOracle),
    ...stringSetFrom(coverage.dartBehavior),
  ])
  if (isRecord(coverage.limited)) {
    for (const module of Object.keys(coverage.limited)) {
      const trimmed = module.trim()
      if (trimmed.length > 0) {
        modules.add(trimmed)
      }
    }
  }
  return modules
}

function upstreamModuleEntry(fileName, manualSpecialModules) {
  const module = fileName.replace(/\.js$/, '')
  const source = fs.readFileSync(path.join(upstreamModuleDir, fileName), 'utf8')
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
    special: manualSpecialModules.has(module) || pathTemplate === '' || !upstreamManifestSupportedCrypto.has(crypto),
  }
}

function loadUpstreamModuleEntries(manualSpecialModules) {
  return fs
    .readdirSync(upstreamModuleDir)
    .filter((file) => file.endsWith('.js'))
    .sort()
    .map((file) => upstreamModuleEntry(file, manualSpecialModules))
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

function loadRawDispatcherModules() {
  const source = fs.readFileSync(rawDispatcherPath, 'utf8')
  const methodStart = source.indexOf('Future<dynamic> requestModule(')
  if (methodStart === -1) {
    throw new Error(`Cannot find requestModule dispatcher: ${rawDispatcherPath}`)
  }
  const switchStart = source.indexOf('switch (module)', methodStart)
  const fallbackStart = source.indexOf('\n    final response =', switchStart)
  if (switchStart === -1 || fallbackStart === -1 || fallbackStart <= switchStart) {
    throw new Error(`Cannot parse requestModule dispatcher: ${rawDispatcherPath}`)
  }
  const switchSource = source.slice(switchStart, fallbackStart)
  return [...switchSource.matchAll(/case\s+'([^']+)'\s*:/g)].map((match) => match[1]).sort()
}

function loadRawConvenienceMethods() {
  const source = fs.readFileSync(rawMethodsPath, 'utf8')
  return [
    ...source.matchAll(
      /Future<dynamic>\s+([A-Za-z0-9_]+)\s*\(\s*Map<String,\s*dynamic>\s+query\s*,?\s*\)\s*=>\s*requestModule\('([^']+)'\s*,\s*query\);/g,
    ),
  ].map((match) => ({
    methodName: match[1],
    module: match[2],
  }))
}

function loadPublicApiExports() {
  const source = fs.readFileSync(publicApiPath, 'utf8')
  return [...source.matchAll(/export\s+'([^']+)';/g)].map((match) => match[1]).sort()
}

function loadPublicFacadeMixins() {
  const source = fs.readFileSync(publicFacadePath, 'utf8')
  const match = source.match(/class\s+NeteaseMusicApi\s+with\s+([^{]+)/)
  if (!match) {
    return []
  }
  return match[1]
    .split(',')
    .map((name) => name.trim())
    .filter((name) => name.length > 0)
    .sort()
}

function listFilesRecursively(dirPath) {
  const files = []
  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    const entryPath = path.join(dirPath, entry.name)
    if (entry.isDirectory()) {
      files.push(...listFilesRecursively(entryPath))
    } else {
      files.push(entryPath)
    }
  }
  return files.sort()
}

function stripDartComments(source) {
  return source.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '')
}

function loadTypedFacadeMethods() {
  const endpointDir = path.join(repoRoot, 'packages/netease_music_api/lib/src/endpoints')
  const methods = []
  for (const filePath of listFilesRecursively(endpointDir)) {
    if (!filePath.endsWith('.dart') || filePath.includes(`${path.sep}raw${path.sep}`)) {
      continue
    }
    const source = stripDartComments(fs.readFileSync(filePath, 'utf8'))
    const relativeFile = path.relative(repoRoot, filePath).replace(/\\/g, '/')
    for (const line of source.split(/\r?\n/)) {
      const match = line.match(/^\s*(?:@override\s*)?(?:[A-Za-z_$][\w$<>, ?.\[\]]+\s+)+([A-Za-z]\w*)\s*(?:<[^>\n]+>)?\(/)
      if (!match) {
        continue
      }
      const methodName = match[1]
      if (!methodName.startsWith('_')) {
        methods.push({
          methodName,
          file: relativeFile,
        })
      }
    }
  }
  return methods.sort((left, right) => `${left.methodName}:${left.file}`.localeCompare(`${right.methodName}:${right.file}`))
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

function upperFirst(name) {
  return name.length === 0 ? name : `${name[0].toUpperCase()}${name.slice(1)}`
}

function rawAliasName(methodName) {
  return `raw${upperFirst(methodName)}`
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

function orderMismatches(actual, expected) {
  const mismatches = []
  const length = Math.max(actual.length, expected.length)
  for (let index = 0; index < length; index += 1) {
    if (actual[index] !== expected[index]) {
      mismatches.push({
        index,
        actual: actual[index] || null,
        expected: expected[index] || null,
      })
    }
  }
  return mismatches
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

function escapeMarkdownTableCell(value) {
  return `${value ?? ''}`.replace(/\|/g, '\\|').replace(/\n/g, ' ')
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

function validateManifestEntries(entries) {
  const invalid = []
  for (const entry of entries) {
    if (!entry.special && (!entry.pathTemplate || entry.pathTemplate.length === 0)) {
      invalid.push({
        module: entry.module,
        field: 'pathTemplate',
        reason: 'Normal generated manifest modules must have a request path template.',
      })
    }
    if (!entry.special && !generatedManifestSupportedCrypto.has(entry.crypto)) {
      invalid.push({
        module: entry.module,
        field: 'crypto',
        reason: `Normal generated manifest modules must use a supported crypto: ${entry.crypto || '<empty>'}.`,
      })
    }
    if (!generatedManifestSupportedHttpMethods.has(entry.httpMethod)) {
      invalid.push({
        module: entry.module,
        field: 'httpMethod',
        reason: `Generated manifest httpMethod must be GET or POST: ${entry.httpMethod || '<empty>'}.`,
      })
    }
  }
  return invalid.sort((left, right) => `${left.module}:${left.field}`.localeCompare(`${right.module}:${right.field}`))
}

function manifestEntriesDiffer(left, right) {
  for (const field of ['module', 'methodName', 'pathTemplate', 'crypto', 'httpMethod', 'special']) {
    if (left[field] !== right[field]) {
      return field
    }
  }
  return null
}

function validateManifestMapEntries(entries, mapEntries) {
  const byModule = new Map(entries.map((entry) => [entry.module, entry]))
  const mismatches = []
  for (const mapEntry of mapEntries) {
    if (mapEntry.key !== mapEntry.module) {
      mismatches.push({
        module: mapEntry.key,
        field: 'module',
        reason: `Manifest map key ${mapEntry.key} points to module ${mapEntry.module}.`,
      })
      continue
    }
    const listEntry = byModule.get(mapEntry.key)
    if (!listEntry) {
      continue
    }
    const mismatchField = manifestEntriesDiffer(listEntry, mapEntry)
    if (mismatchField) {
      mismatches.push({
        module: mapEntry.key,
        field: mismatchField,
        reason: `Manifest map entry for ${mapEntry.key} does not match list entry field ${mismatchField}.`,
      })
    }
  }
  return mismatches.sort((left, right) => `${left.module}:${left.field}`.localeCompare(`${right.module}:${right.field}`))
}

function findManifestUpstreamMetadataMismatches(entries, upstreamEntries) {
  const upstreamByModule = new Map(upstreamEntries.map((entry) => [entry.module, entry]))
  const mismatches = []
  for (const entry of entries) {
    const upstreamEntry = upstreamByModule.get(entry.module)
    if (!upstreamEntry) {
      continue
    }
    for (const field of ['methodName', 'pathTemplate', 'crypto', 'httpMethod', 'special']) {
      if (entry[field] !== upstreamEntry[field]) {
        mismatches.push({
          module: entry.module,
          field,
          manifest: entry[field],
          upstream: upstreamEntry[field],
        })
      }
    }
  }
  return mismatches.sort((left, right) => `${left.module}:${left.field}`.localeCompare(`${right.module}:${right.field}`))
}

function facadeMethodCollisions(rawMethods, typedMethods) {
  const typedByName = new Map()
  for (const method of typedMethods) {
    const files = typedByName.get(method.methodName) || new Set()
    files.add(method.file)
    typedByName.set(method.methodName, files)
  }
  return rawMethods
    .filter((entry) => typedByName.has(entry.methodName))
    .map((entry) => ({
      module: entry.module,
      methodName: entry.methodName,
      typedFiles: sorted([...typedByName.get(entry.methodName)]),
    }))
    .sort((left, right) => left.module.localeCompare(right.module))
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

function validateSpecialCoverageOrder(coverage) {
  if (!isRecord(coverage)) {
    return []
  }

  const mismatches = []
  for (const field of ['nodeOracle', 'dartBehavior']) {
    if (!Array.isArray(coverage[field])) {
      continue
    }
    const entries = coverage[field]
      .filter((item) => typeof item === 'string')
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
    for (const mismatch of orderMismatches(entries, sorted(entries))) {
      mismatches.push({
        field,
        ...mismatch,
      })
    }
  }

  if (isRecord(coverage.limited)) {
    const entries = Object.keys(coverage.limited)
    for (const mismatch of orderMismatches(entries, sorted(entries))) {
      mismatches.push({
        field: 'limited',
        ...mismatch,
      })
    }
  }

  return mismatches.sort((left, right) => `${left.field}:${left.index}`.localeCompare(`${right.field}:${right.index}`))
}

const upstreamPackage = readJson(upstreamPackagePath)
const coverage = readJson(specialCoveragePath)
const specialCoverage = isRecord(coverage) ? coverage : {}
const manualSpecialModules = manualSpecialModulesFromCoverage(specialCoverage)
const upstreamEntries = loadUpstreamModuleEntries(manualSpecialModules)
const upstreamModules = upstreamEntries.map((entry) => entry.module)
const manifest = loadManifest()
const entries = manifest.entries
const oracleFixtures = loadOracleFixtures()
const rawConvenienceMethodEntries = loadRawConvenienceMethods()
const typedFacadeMethods = loadTypedFacadeMethods()
const rawDispatcherModules = loadRawDispatcherModules()
const publicApiExports = loadPublicApiExports()
const publicFacadeMixins = loadPublicFacadeMixins()
const oracleFixtureList = Array.isArray(oracleFixtures) ? oracleFixtures : []
const oracleModuleList = oracleFixtureList
  .filter((fixture) => isRecord(fixture))
  .map((fixture) => fixture.module)
  .filter((module) => typeof module === 'string')
const oracleModules = new Set(oracleModuleList)
const manifestModules = entries.map((entry) => entry.module)
const manifestMethodNames = entries.map((entry) => entry.methodName)
const manifestMethodNameByModule = new Map(entries.map((entry) => [entry.module, entry.methodName]))
const rawConvenienceAliasMethods = rawConvenienceMethodEntries.filter((entry) => {
  const manifestMethodName = manifestMethodNameByModule.get(entry.module)
  return manifestMethodName && entry.methodName === rawAliasName(manifestMethodName)
})
const rawConvenienceMethods = rawConvenienceMethodEntries.filter((entry) => {
  const manifestMethodName = manifestMethodNameByModule.get(entry.module)
  return !(manifestMethodName && entry.methodName === rawAliasName(manifestMethodName))
})
const manifestMapEntries = manifest.mapEntries
const manifestMapKeys = manifestMapEntries.map((entry) => entry.key)
const rawConvenienceModules = rawConvenienceMethods.map((entry) => entry.module)
const rawConvenienceMethodNames = rawConvenienceMethods.map((entry) => entry.methodName)
const rawConvenienceAliasModules = rawConvenienceAliasMethods.map((entry) => entry.module)
const rawConvenienceAliasMethodNames = rawConvenienceAliasMethods.map((entry) => entry.methodName)
const publicApiExportSet = new Set(publicApiExports)
const publicFacadeMixinSet = new Set(publicFacadeMixins)
const upstreamModuleSet = new Set(upstreamModules)
const manifestModuleSet = new Set(manifestModules)
const rawConvenienceModuleSet = new Set(rawConvenienceModules)
const rawConvenienceAliasModuleSet = new Set(rawConvenienceAliasModules)
const normalModules = entries.filter((entry) => !entry.special).map((entry) => entry.module)
const specialModules = entries.filter((entry) => entry.special).map((entry) => entry.module)
const specialSet = new Set(specialModules)
const rawDispatcherModuleSet = new Set(rawDispatcherModules)
const nodeOracleSpecial = stringSetFrom(specialCoverage.nodeOracle)
const dartBehaviorSpecial = stringSetFrom(specialCoverage.dartBehavior)
const specialLimitedReasons = sortedObject(specialCoverage.limited)
const runtimeLimitedReasons = sortedObject({
  'runtime:proxy.pac':
    'proxy 支持 HTTP/HTTPS 代理 URL 和基础认证；明确的 PAC 文件或 PAC scheme 暂不支持，Dart client 会显式抛 UnsupportedError。',
  'runtime:source_order':
    'source order 只属于 song_url_v1 的 unblock 解灰路径；Dart SDK 当前未实现 unblockmusic-utils，普通 xeapi 播放 URL 请求会忽略 source，并在 request options.extra.unsupportedRuntimeOptions 标记 runtime:source_order。',
})
const limitedSpecial = new Set(Object.keys(specialLimitedReasons))
const categorizedSpecial = new Set([...nodeOracleSpecial, ...dartBehaviorSpecial, ...limitedSpecial])
const upstreamCommit = gitOutput(['-C', upstreamRepoPath, 'rev-parse', 'HEAD'])
const submoduleStatus = gitOutput(['-C', upstreamRepoPath, 'status', '--porcelain']) || ''
const manifestDuplicateModules = duplicateValues(manifestModules)
const manifestDuplicateMethodNames = duplicateValues(manifestMethodNames)
const manifestInvalidEntries = validateManifestEntries(entries)
const manifestModuleOrderMismatches = orderMismatches(manifestModules, upstreamModules)
const manifestMapDuplicateKeys = duplicateValues(manifestMapKeys)
const manifestMapMissingModules = sorted(manifestModules.filter((module) => !new Set(manifestMapKeys).has(module)))
const manifestMapUnknownModules = sorted(manifestMapKeys.filter((module) => !manifestModuleSet.has(module)))
const manifestMapEntryMismatches = validateManifestMapEntries(entries, manifestMapEntries)
const manifestMapOrderMismatches = orderMismatches(manifestMapKeys, manifestModules)
const manifestUpstreamMetadataMismatches = findManifestUpstreamMetadataMismatches(entries, upstreamEntries)
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
const specialCoverageOrderMismatches = validateSpecialCoverageOrder(coverage)
const oracleInvalidFixtures = validateOracleFixtures(oracleFixtures)
const oracleDuplicateFixtures = duplicateFixtures(oracleFixtureList)
const oracleUnknownModules = sorted([...oracleModules].filter((module) => !manifestModuleSet.has(module)))
const rawConvenienceMissingModules = sorted(manifestModules.filter((module) => !rawConvenienceModuleSet.has(module)))
const rawConvenienceUnknownModules = sorted(rawConvenienceModules.filter((module) => !manifestModuleSet.has(module)))
const rawConvenienceDuplicateModules = duplicateValues(rawConvenienceModules)
const rawConvenienceDuplicateMethodNames = duplicateValues(rawConvenienceMethodNames)
const rawConvenienceOrderMismatches = orderMismatches(rawConvenienceModules, manifestModules)
const rawConvenienceMethodNameMismatches = rawConvenienceMethods
  .filter((entry) => manifestMethodNameByModule.has(entry.module) && manifestMethodNameByModule.get(entry.module) !== entry.methodName)
  .map((entry) => ({
    module: entry.module,
    manifestMethodName: manifestMethodNameByModule.get(entry.module),
    rawMethodName: entry.methodName,
  }))
  .sort((left, right) => left.module.localeCompare(right.module))
const rawConvenienceFacadeMethodCollisions = facadeMethodCollisions(rawConvenienceMethods, typedFacadeMethods)
const rawConvenienceAliasMissingModules = sorted(manifestModules.filter((module) => !rawConvenienceAliasModuleSet.has(module)))
const rawConvenienceAliasUnknownModules = sorted(rawConvenienceAliasModules.filter((module) => !manifestModuleSet.has(module)))
const rawConvenienceAliasDuplicateModules = duplicateValues(rawConvenienceAliasModules)
const rawConvenienceAliasDuplicateMethodNames = duplicateValues(rawConvenienceAliasMethodNames)
const rawConvenienceAliasOrderMismatches = orderMismatches(rawConvenienceAliasModules, manifestModules)
const rawConvenienceAliasMethodNameMismatches = rawConvenienceAliasMethods
  .filter((entry) => manifestMethodNameByModule.has(entry.module) && rawAliasName(manifestMethodNameByModule.get(entry.module)) !== entry.methodName)
  .map((entry) => ({
    module: entry.module,
    manifestMethodName: rawAliasName(manifestMethodNameByModule.get(entry.module)),
    rawMethodName: entry.methodName,
  }))
  .sort((left, right) => left.module.localeCompare(right.module))
const rawConvenienceAliasFacadeMethodCollisions = facadeMethodCollisions(rawConvenienceAliasMethods, typedFacadeMethods)
const publicApiMissingExports = expectedPublicApiExports.filter((exportPath) => !publicApiExportSet.has(exportPath))
const publicFacadeMissingMixins = expectedPublicFacadeMixins.filter((mixinName) => !publicFacadeMixinSet.has(mixinName))
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
const specialDispatcherDuplicateCases = duplicateValues(rawDispatcherModules)
const specialDispatcherMissing = sorted(specialModules.filter((module) => !rawDispatcherModuleSet.has(module)))
const specialDispatcherUnknown = sorted(rawDispatcherModules.filter((module) => !specialSet.has(module)))
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
  for (const mismatch of specialCoverageOrderMismatches) {
    differences.push({
      module: mismatch.expected || mismatch.actual || '<special_coverage>',
      status: 'special_coverage_order_mismatch',
      reason: `Special coverage ${mismatch.field} index ${mismatch.index} has ${mismatch.actual || '<missing>'}, expected ${mismatch.expected || '<missing>'}.`,
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
  for (const entry of manifestInvalidEntries) {
    differences.push({
      module: entry.module,
      status: 'invalid_manifest_entry',
      reason: `${entry.field}: ${entry.reason}`,
      scope: 'generated_manifest',
    })
  }
  for (const module of manifestMapMissingModules) {
    differences.push({
      module,
      status: 'missing_manifest_map_entry',
      reason: 'Generated manifest map does not include this list module.',
      scope: 'generated_manifest',
    })
  }
  for (const mismatch of manifestModuleOrderMismatches) {
    differences.push({
      module: mismatch.expected || mismatch.actual || '<generated_manifest>',
      status: 'manifest_module_order_mismatch',
      reason: `Generated manifest list index ${mismatch.index} has ${mismatch.actual || '<missing>'}, expected ${mismatch.expected || '<missing>'}.`,
      scope: 'generated_manifest',
    })
  }
  for (const module of manifestMapUnknownModules) {
    differences.push({
      module,
      status: 'unknown_manifest_map_entry',
      reason: 'Generated manifest map includes a module that is not present in the manifest list.',
      scope: 'generated_manifest',
    })
  }
  for (const module of manifestMapDuplicateKeys) {
    differences.push({
      module,
      status: 'duplicate_manifest_map_key',
      reason: 'Generated manifest map defines this module key more than once.',
      scope: 'generated_manifest',
    })
  }
  for (const mismatch of manifestMapEntryMismatches) {
    differences.push({
      module: mismatch.module,
      status: 'manifest_map_entry_mismatch',
      reason: `${mismatch.field}: ${mismatch.reason}`,
      scope: 'generated_manifest',
    })
  }
  for (const mismatch of manifestMapOrderMismatches) {
    differences.push({
      module: mismatch.expected || mismatch.actual || '<generated_manifest>',
      status: 'manifest_map_order_mismatch',
      reason: `Generated manifest map index ${mismatch.index} has ${mismatch.actual || '<missing>'}, expected ${mismatch.expected || '<missing>'}.`,
      scope: 'generated_manifest',
    })
  }
  for (const mismatch of manifestUpstreamMetadataMismatches) {
    differences.push({
      module: mismatch.module,
      status: 'manifest_upstream_metadata_mismatch',
      reason: `Generated manifest ${mismatch.field} ${mismatch.manifest ?? '<missing>'} does not match upstream ${mismatch.upstream ?? '<missing>'}.`,
      scope: 'generated_manifest',
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
  for (const module of rawConvenienceMissingModules) {
    differences.push({
      module,
      status: 'missing_raw_convenience_method',
      reason: 'Generated raw convenience methods do not include this manifest module.',
      scope: 'raw_convenience_methods',
    })
  }
  for (const module of rawConvenienceUnknownModules) {
    differences.push({
      module,
      status: 'unknown_raw_convenience_method',
      reason: 'Generated raw convenience methods reference a module that is not in the manifest.',
      scope: 'raw_convenience_methods',
    })
  }
  for (const module of rawConvenienceDuplicateModules) {
    differences.push({
      module,
      status: 'duplicate_raw_convenience_module',
      reason: 'Generated raw convenience methods reference this module more than once.',
      scope: 'raw_convenience_methods',
    })
  }
  for (const mismatch of rawConvenienceOrderMismatches) {
    differences.push({
      module: mismatch.expected || mismatch.actual || '<raw_convenience_methods>',
      status: 'raw_convenience_order_mismatch',
      reason: `Generated raw convenience method index ${mismatch.index} has ${mismatch.actual || '<missing>'}, expected ${mismatch.expected || '<missing>'}.`,
      scope: 'raw_convenience_methods',
    })
  }
  for (const methodName of rawConvenienceDuplicateMethodNames) {
    differences.push({
      module: '<raw_convenience_methods>',
      status: 'duplicate_raw_convenience_method_name',
      reason: `Generated raw convenience method name ${methodName} appears more than once.`,
      scope: 'raw_convenience_methods',
    })
  }
  for (const mismatch of rawConvenienceMethodNameMismatches) {
    differences.push({
      module: mismatch.module,
      status: 'raw_convenience_method_name_mismatch',
      reason: `Generated raw convenience method name ${mismatch.rawMethodName} does not match manifest method name ${mismatch.manifestMethodName}.`,
      scope: 'raw_convenience_methods',
    })
  }
  for (const module of rawConvenienceAliasMissingModules) {
    differences.push({
      module,
      status: 'missing_raw_convenience_alias',
      reason: 'Generated raw convenience aliases do not include this manifest module.',
      scope: 'raw_convenience_aliases',
    })
  }
  for (const module of rawConvenienceAliasUnknownModules) {
    differences.push({
      module,
      status: 'unknown_raw_convenience_alias',
      reason: 'Generated raw convenience aliases reference a module that is not in the manifest.',
      scope: 'raw_convenience_aliases',
    })
  }
  for (const module of rawConvenienceAliasDuplicateModules) {
    differences.push({
      module,
      status: 'duplicate_raw_convenience_alias_module',
      reason: 'Generated raw convenience aliases reference this module more than once.',
      scope: 'raw_convenience_aliases',
    })
  }
  for (const mismatch of rawConvenienceAliasOrderMismatches) {
    differences.push({
      module: mismatch.expected || mismatch.actual || '<raw_convenience_aliases>',
      status: 'raw_convenience_alias_order_mismatch',
      reason: `Generated raw convenience alias index ${mismatch.index} has ${mismatch.actual || '<missing>'}, expected ${mismatch.expected || '<missing>'}.`,
      scope: 'raw_convenience_aliases',
    })
  }
  for (const methodName of rawConvenienceAliasDuplicateMethodNames) {
    differences.push({
      module: '<raw_convenience_aliases>',
      status: 'duplicate_raw_convenience_alias_name',
      reason: `Generated raw convenience alias name ${methodName} appears more than once.`,
      scope: 'raw_convenience_aliases',
    })
  }
  for (const mismatch of rawConvenienceAliasMethodNameMismatches) {
    differences.push({
      module: mismatch.module,
      status: 'raw_convenience_alias_name_mismatch',
      reason: `Generated raw convenience alias name ${mismatch.rawMethodName} does not match expected alias ${mismatch.manifestMethodName}.`,
      scope: 'raw_convenience_aliases',
    })
  }
  for (const collision of rawConvenienceAliasFacadeMethodCollisions) {
    differences.push({
      module: collision.module,
      status: 'raw_convenience_alias_facade_collision',
      reason: `Generated raw convenience alias ${collision.methodName} is shadowed by typed facade methods: ${collision.typedFiles.join(', ')}.`,
      scope: 'raw_convenience_aliases',
    })
  }
  for (const exportPath of publicApiMissingExports) {
    differences.push({
      module: exportPath,
      status: 'missing_public_api_export',
      reason: 'Public package barrel must export the typed SDK facade, shared SDK beans, and raw api-enhanced dispatcher.',
      scope: 'public_api',
    })
  }
  for (const mixinName of publicFacadeMissingMixins) {
    differences.push({
      module: mixinName,
      status: 'missing_public_facade_mixin',
      reason: 'NeteaseMusicApi must keep typed endpoint mixins and ApiEnhancedRaw on the same public facade.',
      scope: 'public_facade',
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
  for (const module of specialDispatcherMissing) {
    differences.push({
      module,
      status: 'missing_special_dispatcher',
      reason: 'Special module has no requestModule dispatcher case.',
      scope: 'raw_dispatcher',
    })
  }
  for (const module of specialDispatcherDuplicateCases) {
    differences.push({
      module,
      status: 'duplicate_special_dispatcher',
      reason: 'requestModule dispatcher defines this special module case more than once.',
      scope: 'raw_dispatcher',
    })
  }
  for (const module of specialDispatcherUnknown) {
    differences.push({
      module,
      status: 'unknown_special_dispatcher',
      reason: 'requestModule dispatcher handles a module that is not marked as special in the generated manifest.',
      scope: 'raw_dispatcher',
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
      status: limitedSpecial.has(module) ? 'limited' : coverage.length > 0 ? 'covered' : 'missing',
      coverage,
      hasNodeOracleFixture: oracleModules.has(module),
      limitedReason: specialLimitedReasons[module] || null,
    }
  }
  return statusByModule
}

function buildStatusCounts(statusByName, statuses) {
  const counts = Object.fromEntries(statuses.map((status) => [status, 0]))
  for (const status of Object.values(statusByName)) {
    counts[status.status] = (counts[status.status] || 0) + 1
  }
  return sortedObject(counts)
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

const specialCoverageStatusByModule = buildSpecialCoverageStatusByModule()
const runtimeOptionStatusByName = buildRuntimeOptionStatusByName()

const report = {
  schemaVersion: coverageReportSchemaVersion,
  upstreamVersion: upstreamPackage.version,
  upstreamSubmodulePath: path.relative(repoRoot, upstreamRepoPath).replace(/\\/g, '/'),
  upstreamCommit,
  upstreamDirty: submoduleStatus.length > 0,
  manifestUpstreamVersion: manifest.upstreamVersion,
  manifestUpstreamCommit: manifest.upstreamCommit,
  manifestUpstreamMismatches,
  manifestDuplicateModules,
  manifestDuplicateMethodNames,
  manifestInvalidEntries,
  manifestModuleOrderMismatches,
  manifestMapEntryCount: manifestMapEntries.length,
  manifestMapDuplicateKeys,
  manifestMapMissingModules,
  manifestMapUnknownModules,
  manifestMapEntryMismatches,
  manifestMapOrderMismatches,
  manifestUpstreamMetadataMismatches,
  specialCoverageInvalidEntries,
  specialCoverageDuplicateEntries,
  specialCoverageOrderMismatches,
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
  rawConvenienceMethodCount: rawConvenienceMethods.length,
  rawConvenienceMissingModules,
  rawConvenienceUnknownModules,
  rawConvenienceDuplicateModules,
  rawConvenienceDuplicateMethodNames,
  rawConvenienceOrderMismatches,
  rawConvenienceMethodNameMismatches,
  rawConvenienceFacadeMethodCollisionCount: rawConvenienceFacadeMethodCollisions.length,
  rawConvenienceFacadeMethodCollisions,
  rawConvenienceAliasCount: rawConvenienceAliasMethods.length,
  rawConvenienceAliasMissingModules,
  rawConvenienceAliasUnknownModules,
  rawConvenienceAliasDuplicateModules,
  rawConvenienceAliasDuplicateMethodNames,
  rawConvenienceAliasOrderMismatches,
  rawConvenienceAliasMethodNameMismatches,
  rawConvenienceAliasFacadeMethodCollisionCount: rawConvenienceAliasFacadeMethodCollisions.length,
  rawConvenienceAliasFacadeMethodCollisions,
  publicApiExports,
  publicApiExpectedExports: expectedPublicApiExports,
  publicApiMissingExports,
  publicFacadeMixins,
  publicFacadeExpectedMixins: expectedPublicFacadeMixins,
  publicFacadeMissingMixins,
  publicFacadeTypedMixinCount: expectedTypedFacadeMixins.filter((mixinName) => publicFacadeMixinSet.has(mixinName)).length,
  publicFacadeHasRawMixin: expectedRawFacadeMixins.every((mixinName) => publicFacadeMixinSet.has(mixinName)),
  normalMissingOracle,
  specialMissingStatus,
  specialUnknownStatus,
  specialNodeOracleMissingFixture,
  specialNonLimitedMissingOracle,
  specialLimitedMissingReason,
  specialDispatcherDuplicateCases,
  specialDispatcherMissing,
  specialDispatcherUnknown,
  specialNodeOracle: sorted(nodeOracleSpecial),
  specialDartBehavior: sorted(dartBehaviorSpecial),
  specialLimited: sorted(limitedSpecial),
  runtimeSupported: sorted(runtimeSupported),
  runtimeLimited: sorted(runtimeLimited),
  specialCoverageStatusByModule,
  specialCoverageStatusCounts: buildStatusCounts(specialCoverageStatusByModule, ['covered', 'limited', 'missing']),
  runtimeOptionStatusByName,
  runtimeOptionStatusCounts: buildStatusCounts(runtimeOptionStatusByName, ['supported', 'limited']),
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
  report.manifestInvalidEntries.length > 0 ||
  report.manifestModuleOrderMismatches.length > 0 ||
  report.manifestMapDuplicateKeys.length > 0 ||
  report.manifestMapMissingModules.length > 0 ||
  report.manifestMapUnknownModules.length > 0 ||
  report.manifestMapEntryMismatches.length > 0 ||
  report.manifestMapOrderMismatches.length > 0 ||
  report.manifestUpstreamMetadataMismatches.length > 0 ||
  report.specialCoverageInvalidEntries.length > 0 ||
  report.specialCoverageDuplicateEntries.length > 0 ||
  report.specialCoverageOrderMismatches.length > 0 ||
  report.manifestMissingUpstreamModules.length > 0 ||
  report.manifestUnknownUpstreamModules.length > 0 ||
  report.oracleInvalidFixtures.length > 0 ||
  report.oracleDuplicateFixtures.length > 0 ||
  report.oracleUnknownModules.length > 0 ||
  report.rawConvenienceMissingModules.length > 0 ||
  report.rawConvenienceUnknownModules.length > 0 ||
  report.rawConvenienceDuplicateModules.length > 0 ||
  report.rawConvenienceDuplicateMethodNames.length > 0 ||
  report.rawConvenienceOrderMismatches.length > 0 ||
  report.rawConvenienceMethodNameMismatches.length > 0 ||
  report.rawConvenienceAliasMissingModules.length > 0 ||
  report.rawConvenienceAliasUnknownModules.length > 0 ||
  report.rawConvenienceAliasDuplicateModules.length > 0 ||
  report.rawConvenienceAliasDuplicateMethodNames.length > 0 ||
  report.rawConvenienceAliasOrderMismatches.length > 0 ||
  report.rawConvenienceAliasMethodNameMismatches.length > 0 ||
  report.rawConvenienceAliasFacadeMethodCollisions.length > 0 ||
  report.publicApiMissingExports.length > 0 ||
  report.publicFacadeMissingMixins.length > 0 ||
  report.normalMissingOracle.length > 0 ||
  report.specialMissingStatus.length > 0 ||
  report.specialUnknownStatus.length > 0 ||
  report.specialNodeOracleMissingFixture.length > 0 ||
  report.specialNonLimitedMissingOracle.length > 0 ||
  report.specialLimitedMissingReason.length > 0 ||
  report.specialDispatcherDuplicateCases.length > 0 ||
  report.specialDispatcherMissing.length > 0 ||
  report.specialDispatcherUnknown.length > 0

function renderMarkdownReport(report) {
  const lines = [
    '# api-enhanced coverage report',
    '',
    '## Upstream',
    '',
    `- schema version: ${report.schemaVersion}`,
    `- version: ${report.upstreamVersion}`,
    `- submodule: ${report.upstreamSubmodulePath}`,
    `- commit: ${report.upstreamCommit || 'unknown'}`,
    `- dirty: ${report.upstreamDirty}`,
    `- manifest version: ${report.manifestUpstreamVersion || 'unknown'}`,
    `- manifest commit: ${report.manifestUpstreamCommit || 'unknown'}`,
    `- upstream metadata mismatches: ${report.manifestUpstreamMetadataMismatches.length}`,
    '',
    '## Coverage',
    '',
    `- modules: ${report.moduleCount}`,
    `- upstream module files: ${report.upstreamModuleFileCount}`,
    `- normal modules: ${report.normalModuleCount}`,
    `- special modules: ${report.specialModuleCount}`,
    `- node oracle scenarios: ${report.nodeOracleScenarioCount}`,
    `- node oracle fixtures: ${report.nodeOracleFixtureCount}`,
    `- raw convenience methods: ${report.rawConvenienceMethodCount}`,
    `- raw convenience aliases: ${report.rawConvenienceAliasCount}`,
    `- raw convenience facade method collisions: ${report.rawConvenienceFacadeMethodCollisionCount}`,
    `- raw convenience alias facade method collisions: ${report.rawConvenienceAliasFacadeMethodCollisionCount}`,
    '',
    '## Public Facade',
    '',
    `- exports: ${report.publicApiExports.join(', ') || 'none'}`,
    `- expected exports: ${report.publicApiExpectedExports.join(', ')}`,
    `- missing exports: ${report.publicApiMissingExports.join(', ') || 'none'}`,
    `- facade mixins: ${report.publicFacadeMixins.join(', ') || 'none'}`,
    `- expected facade mixins: ${report.publicFacadeExpectedMixins.join(', ')}`,
    `- typed facade mixins: ${report.publicFacadeTypedMixinCount}/${expectedTypedFacadeMixins.length}`,
    `- raw facade mixin: ${report.publicFacadeHasRawMixin ? 'yes' : 'no'}`,
    `- missing facade mixins: ${report.publicFacadeMissingMixins.join(', ') || 'none'}`,
    '',
    '## Raw Convenience Method Collisions',
    '',
  ]

  if (report.rawConvenienceFacadeMethodCollisions.length === 0) {
    lines.push('- none')
  } else {
    lines.push('| module | raw method | typed files |')
    lines.push('| --- | --- | --- |')
    for (const collision of report.rawConvenienceFacadeMethodCollisions) {
      lines.push(
        `| ${escapeMarkdownTableCell(collision.module)} | ${escapeMarkdownTableCell(collision.methodName)} | ${escapeMarkdownTableCell(collision.typedFiles.join(', '))} |`,
      )
    }
  }

  lines.push(
    '',
    '## Raw Convenience Aliases',
    '',
    `- aliases: ${report.rawConvenienceAliasCount}`,
    `- missing aliases: ${report.rawConvenienceAliasMissingModules.join(', ') || 'none'}`,
    `- alias facade method collisions: ${report.rawConvenienceAliasFacadeMethodCollisionCount}`,
    '',
    '## Special Modules',
    '',
    `- node oracle: ${report.specialNodeOracle.join(', ') || 'none'}`,
    `- Dart behavior: ${report.specialDartBehavior.join(', ') || 'none'}`,
    `- limited: ${report.specialLimited.join(', ') || 'none'}`,
    `- status counts: covered ${report.specialCoverageStatusCounts.covered || 0}, limited ${report.specialCoverageStatusCounts.limited || 0}, missing ${report.specialCoverageStatusCounts.missing || 0}`,
    '',
    '| module | status | coverage | oracle fixture | limited reason |',
    '| --- | --- | --- | --- | --- |',
  )

  for (const module of Object.keys(report.specialCoverageStatusByModule).sort()) {
    const status = report.specialCoverageStatusByModule[module]
    lines.push(
      `| ${escapeMarkdownTableCell(module)} | ${escapeMarkdownTableCell(status.status)} | ${escapeMarkdownTableCell(status.coverage.join(', ') || 'none')} | ${status.hasNodeOracleFixture ? 'yes' : 'no'} | ${escapeMarkdownTableCell(status.limitedReason || '')} |`,
    )
  }

  lines.push(
    '',
    '## Runtime Options',
    '',
    `- supported: ${report.runtimeSupported.join(', ') || 'none'}`,
    `- limited: ${report.runtimeLimited.join(', ') || 'none'}`,
    `- status counts: supported ${report.runtimeOptionStatusCounts.supported || 0}, limited ${report.runtimeOptionStatusCounts.limited || 0}`,
    '',
    '| option | status | reason |',
    '| --- | --- | --- |',
  )

  for (const option of Object.keys(report.runtimeOptionStatusByName).sort()) {
    const status = report.runtimeOptionStatusByName[option]
    lines.push(
      `| ${escapeMarkdownTableCell(option)} | ${escapeMarkdownTableCell(status.status)} | ${escapeMarkdownTableCell(status.reason)} |`,
    )
  }

  lines.push(
    '',
    '## SDK Differences',
    '',
  )

  if (report.sdkDifferences.length === 0) {
    lines.push('- none')
  } else {
    lines.push('| scope | module | status | reason |')
    lines.push('| --- | --- | --- | --- |')
    for (const difference of report.sdkDifferences) {
      lines.push(
        `| ${escapeMarkdownTableCell(difference.scope)} | ${escapeMarkdownTableCell(difference.module)} | ${escapeMarkdownTableCell(difference.status)} | ${escapeMarkdownTableCell(difference.reason)} |`,
      )
    }
  }
  lines.push('')
  return lines.join('\n')
}

function renderSdkDifferencesDocSection(report) {
  const lines = [
    sdkDifferencesDocStart,
    '',
    '当前 SDK 差异清单由 `api_enhanced_coverage_report.js` 从同一份覆盖报告生成。',
    '',
    `- schemaVersion：${report.schemaVersion}`,
    `- 上游版本：${report.upstreamVersion}`,
    `- 上游 commit：${report.upstreamCommit || 'unknown'}`,
    `- module 覆盖：${report.moduleCount}/${report.upstreamModuleFileCount}`,
    `- special 状态：covered ${report.specialCoverageStatusCounts.covered || 0}，limited ${report.specialCoverageStatusCounts.limited || 0}，missing ${report.specialCoverageStatusCounts.missing || 0}`,
    `- runtime option 状态：supported ${report.runtimeOptionStatusCounts.supported || 0}，limited ${report.runtimeOptionStatusCounts.limited || 0}`,
    '',
    '| scope | module | status | reason |',
    '| --- | --- | --- | --- |',
  ]
  if (report.sdkDifferences.length === 0) {
    lines.push('| none | none | covered | 当前没有已知 SDK 差异。 |')
  } else {
    for (const difference of report.sdkDifferences) {
      lines.push(
        `| ${escapeMarkdownTableCell(difference.scope)} | ${escapeMarkdownTableCell(difference.module)} | ${escapeMarkdownTableCell(difference.status)} | ${escapeMarkdownTableCell(difference.reason)} |`,
      )
    }
  }
  lines.push('', sdkDifferencesDocEnd)
  return lines.join('\n')
}

function replaceSdkDifferencesDocSection(markdown, replacement, filePath) {
  const start = markdown.indexOf(sdkDifferencesDocStart)
  const end = markdown.indexOf(sdkDifferencesDocEnd)
  if (start === -1 || end === -1 || end < start) {
    throw new Error(`Cannot find SDK differences markers in ${path.relative(repoRoot, filePath)}`)
  }
  return `${markdown.slice(0, start)}${replacement}${markdown.slice(end + sdkDifferencesDocEnd.length)}`
}

function syncSdkDifferencesDoc(filePath, { check }) {
  const current = fs.readFileSync(filePath, 'utf8')
  const next = replaceSdkDifferencesDocSection(current, renderSdkDifferencesDocSection(report), filePath)
  if (next === current) {
    return true
  }
  if (check) {
    console.error(`SDK differences doc is stale: ${path.relative(repoRoot, filePath)}`)
    console.error(`Run: node packages/netease_music_api/tool/api_enhanced_coverage_report.js --write-differences-doc=${path.relative(repoRoot, filePath).replace(/\\/g, '/')}`)
    return false
  }
  fs.writeFileSync(filePath, next)
  return true
}

let differencesDocStale = false
try {
  if (writeDifferencesDocPath) {
    syncSdkDifferencesDoc(writeDifferencesDocPath, { check: false })
  }
  if (checkDifferencesDocPath) {
    differencesDocStale = !syncSdkDifferencesDoc(checkDifferencesDocPath, { check: true })
  }
} catch (error) {
  differencesDocStale = true
  console.error(error instanceof Error ? error.message : String(error))
}

if (jsonOutput) {
  console.log(JSON.stringify(report, null, 2))
} else if (markdownOutput) {
  console.log(renderMarkdownReport(report))
} else {
  console.log('api-enhanced coverage report')
  console.log(`schema version: ${report.schemaVersion}`)
  console.log(`upstream version: ${report.upstreamVersion}`)
  console.log(`upstream submodule: ${report.upstreamSubmodulePath}`)
  console.log(`upstream commit: ${report.upstreamCommit || 'unknown'}`)
  console.log(`upstream dirty: ${report.upstreamDirty}`)
  console.log(`manifest upstream version: ${report.manifestUpstreamVersion || 'unknown'}`)
  console.log(`manifest upstream commit: ${report.manifestUpstreamCommit || 'unknown'}`)
  console.log(`manifest upstream mismatches: ${report.manifestUpstreamMismatches.length}`)
  console.log(`manifest duplicate modules: ${report.manifestDuplicateModules.length}`)
  console.log(`manifest duplicate method names: ${report.manifestDuplicateMethodNames.length}`)
  console.log(`manifest invalid entries: ${report.manifestInvalidEntries.length}`)
  console.log(`manifest module order mismatches: ${report.manifestModuleOrderMismatches.length}`)
  console.log(`manifest map entries: ${report.manifestMapEntryCount}`)
  console.log(`manifest map duplicate keys: ${report.manifestMapDuplicateKeys.length}`)
  console.log(`manifest map missing modules: ${report.manifestMapMissingModules.length}`)
  console.log(`manifest map unknown modules: ${report.manifestMapUnknownModules.length}`)
  console.log(`manifest map entry mismatches: ${report.manifestMapEntryMismatches.length}`)
  console.log(`manifest map order mismatches: ${report.manifestMapOrderMismatches.length}`)
  console.log(`manifest upstream metadata mismatches: ${report.manifestUpstreamMetadataMismatches.length}`)
  console.log(`special coverage invalid entries: ${report.specialCoverageInvalidEntries.length}`)
  console.log(`special coverage duplicate entries: ${report.specialCoverageDuplicateEntries.length}`)
  console.log(`special coverage order mismatches: ${report.specialCoverageOrderMismatches.length}`)
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
  console.log(`raw convenience methods: ${report.rawConvenienceMethodCount}`)
  console.log(`raw convenience missing modules: ${report.rawConvenienceMissingModules.length}`)
  console.log(`raw convenience unknown modules: ${report.rawConvenienceUnknownModules.length}`)
  console.log(`raw convenience duplicate modules: ${report.rawConvenienceDuplicateModules.length}`)
  console.log(`raw convenience duplicate method names: ${report.rawConvenienceDuplicateMethodNames.length}`)
  console.log(`raw convenience order mismatches: ${report.rawConvenienceOrderMismatches.length}`)
  console.log(`raw convenience method name mismatches: ${report.rawConvenienceMethodNameMismatches.length}`)
  console.log(`raw convenience facade method collisions: ${report.rawConvenienceFacadeMethodCollisionCount}`)
  console.log(`raw convenience aliases: ${report.rawConvenienceAliasCount}`)
  console.log(`raw convenience alias missing modules: ${report.rawConvenienceAliasMissingModules.length}`)
  console.log(`raw convenience alias unknown modules: ${report.rawConvenienceAliasUnknownModules.length}`)
  console.log(`raw convenience alias duplicate modules: ${report.rawConvenienceAliasDuplicateModules.length}`)
  console.log(`raw convenience alias duplicate method names: ${report.rawConvenienceAliasDuplicateMethodNames.length}`)
  console.log(`raw convenience alias order mismatches: ${report.rawConvenienceAliasOrderMismatches.length}`)
  console.log(`raw convenience alias method name mismatches: ${report.rawConvenienceAliasMethodNameMismatches.length}`)
  console.log(`raw convenience alias facade method collisions: ${report.rawConvenienceAliasFacadeMethodCollisionCount}`)
  console.log(`public api exports: ${report.publicApiExports.join(', ')}`)
  console.log(`public api missing exports: ${report.publicApiMissingExports.length}`)
  console.log(`public facade mixins: ${report.publicFacadeMixins.join(', ')}`)
  console.log(`public facade typed mixins: ${report.publicFacadeTypedMixinCount}/${expectedTypedFacadeMixins.length}`)
  console.log(`public facade raw mixin: ${report.publicFacadeHasRawMixin}`)
  console.log(`public facade missing mixins: ${report.publicFacadeMissingMixins.length}`)
  console.log(`normal modules missing oracle: ${report.normalMissingOracle.length}`)
  console.log(`special modules missing status: ${report.specialMissingStatus.length}`)
  console.log(`special node-oracle modules missing fixture: ${report.specialNodeOracleMissingFixture.length}`)
  console.log(`special non-limited modules missing oracle: ${report.specialNonLimitedMissingOracle.length}`)
  console.log(`special limited modules missing reason: ${report.specialLimitedMissingReason.length}`)
  console.log(`special dispatcher duplicate cases: ${report.specialDispatcherDuplicateCases.length}`)
  console.log(`special dispatcher missing cases: ${report.specialDispatcherMissing.length}`)
  console.log(`special dispatcher unknown cases: ${report.specialDispatcherUnknown.length}`)
  console.log(`special status unknown modules: ${report.specialUnknownStatus.length}`)
  console.log(`special node oracle: ${report.specialNodeOracle.join(', ')}`)
  console.log(`special dart behavior: ${report.specialDartBehavior.join(', ')}`)
  console.log(`special limited: ${report.specialLimited.join(', ')}`)
  console.log(`runtime supported: ${report.runtimeSupported.join(', ')}`)
  console.log(`runtime limited: ${report.runtimeLimited.join(', ')}`)
  console.log(`special coverage status entries: ${Object.keys(report.specialCoverageStatusByModule).length}`)
  console.log(`special coverage status counts: ${JSON.stringify(report.specialCoverageStatusCounts)}`)
  console.log(`runtime option status entries: ${Object.keys(report.runtimeOptionStatusByName).length}`)
  console.log(`runtime option status counts: ${JSON.stringify(report.runtimeOptionStatusCounts)}`)
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

process.exitCode = hasFailure || differencesDocStale ? 1 : 0
