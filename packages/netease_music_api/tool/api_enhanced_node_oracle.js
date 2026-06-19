#!/usr/bin/env node

const path = require('path')

const repoRoot = path.resolve(__dirname, '../../..')
const upstreamRoot = path.join(repoRoot, 'third_party/api-enhanced')

const fixtures = [
  {
    module: 'album',
    query: {
      id: '456',
      realIP: '1.2.3.4',
      ua: 'unit-test',
      domain: 'https://example.test',
      checkToken: true,
      proxy: 'http://127.0.0.1:8080',
      cookie: { MUSIC_U: 'token' },
    },
  },
  {
    module: 'album_privilege',
    query: {
      id: '456',
    },
  },
  {
    module: 'search',
    query: {
      keywords: 'hello',
      type: 1,
      limit: 20,
      offset: 5,
    },
  },
  {
    module: 'search',
    query: {
      keywords: 'voice',
      type: '2000',
      limit: 10,
      offset: 0,
    },
  },
  {
    module: 'song_detail',
    query: {
      ids: '101, 202',
    },
  },
  {
    module: 'lyric_new',
    query: {
      id: '101',
    },
  },
  {
    module: 'playlist_detail',
    query: {
      id: '888',
      s: 4,
    },
  },
  {
    module: 'playlist_subscribe',
    query: {
      id: '888',
      t: 1,
    },
  },
  {
    module: 'playlist_subscribe',
    query: {
      id: '888',
      t: 2,
    },
  },
  {
    module: 'playlist_tracks',
    query: {
      op: 'add',
      pid: '888',
      tracks: '101,202',
    },
  },
  {
    module: 'user_playlist',
    query: {
      uid: '42',
    },
  },
  {
    module: 'song_url',
    query: {
      id: '101,202',
    },
  },
  {
    module: 'like',
    query: {
      id: '101',
      like: 'false',
    },
  },
  {
    module: 'cloudsearch',
    query: {
      keywords: 'hello',
    },
  },
  {
    module: 'personalized',
    query: {},
  },
  {
    module: 'recommend_songs',
    query: {
      afresh: true,
    },
  },
  {
    module: 'search_hot_detail',
    query: {},
  },
  {
    module: 'voicelist_search',
    query: {
      keyword: 'podcast',
    },
  },
]

async function captureFixture(fixture) {
  const modulePath = path.join(upstreamRoot, 'module', `${fixture.module}.js`)
  const upstreamModule = require(modulePath)
  const query = JSON.parse(JSON.stringify(fixture.query))
  let captured = null
  const request = (uri, data, options) => {
    captured = { uri, data, options }
    return Promise.resolve({ status: 200, body: { code: 200, data: [] }, cookie: [] })
  }

  await upstreamModule(query, request)
  if (!captured) {
    throw new Error(`Module ${fixture.module} did not call request`)
  }
  return {
    module: fixture.module,
    query: fixture.query,
    ...captured,
  }
}

async function main() {
  const results = []
  for (const fixture of fixtures) {
    results.push(await captureFixture(fixture))
  }
  process.stdout.write(`${JSON.stringify(results, null, 2)}\n`)
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
