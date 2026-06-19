#!/usr/bin/env node

const path = require('path')
const crypto = require('crypto')
const Module = require('module')

const repoRoot = path.resolve(__dirname, '../../..')
const upstreamRoot = path.join(repoRoot, 'third_party/api-enhanced')

const originalRequire = Module.prototype.require
Module.prototype.require = function patchedRequire(request) {
  if (request === 'crypto-js') {
    return {
      MD5(value) {
        const digest = crypto.createHash('md5').update(String(value)).digest('hex')
        return { toString: () => digest }
      },
    }
  }
  return originalRequire.apply(this, arguments)
}

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
    module: 'album',
    query: {
      id: '456',
      crypto: 'api',
    },
  },
  {
    module: 'album',
    query: {
      id: '456',
      crypto: 'linuxapi',
    },
  },
  {
    module: 'album',
    query: {
      id: '456',
      crypto: 'xeapi',
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
    module: 'login',
    query: {
      email: 'user@example.test',
      password: 'secret',
    },
  },
  {
    module: 'login_cellphone',
    query: {
      phone: '13800000000',
      password: 'secret',
      countrycode: '86',
    },
  },
  {
    module: 'login_cellphone',
    query: {
      phone: '13800000000',
      captcha: '1234',
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
    module: 'playlist_detail_dynamic',
    query: {
      id: '888',
      s: 4,
    },
  },
  {
    module: 'playlist_hot',
    query: {},
  },
  {
    module: 'top_playlist',
    query: {
      cat: '华语',
      order: 'new',
      limit: 12,
      offset: 24,
    },
  },
  {
    module: 'top_playlist_highquality',
    query: {
      cat: '民谣',
      limit: 10,
      before: 123456,
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
    module: 'song_url',
    query: {
      id: '101,202',
      br: 320000,
      crypto: 'xeapi',
    },
  },
  {
    module: 'comment_music',
    query: {
      id: '101',
      limit: 10,
      offset: 20,
      before: 123456,
    },
  },
  {
    module: 'comment_playlist',
    query: {
      id: '888',
      limit: 10,
      offset: 20,
      before: 123456,
    },
  },
  {
    module: 'comment_hot',
    query: {
      type: 0,
      id: '101',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'comment_new',
    query: {
      type: 0,
      id: '101',
      pageSize: 10,
      pageNo: 2,
      sortType: 2,
    },
  },
  {
    module: 'comment_like',
    query: {
      type: 0,
      id: '101',
      cid: '555',
      t: 1,
    },
  },
  {
    module: 'comment_like',
    query: {
      type: 6,
      id: '101',
      threadId: 'A_EV_2_101',
      cid: '555',
      t: 0,
    },
  },
  {
    module: 'comment_floor',
    query: {
      type: 2,
      id: '888',
      parentCommentId: '777',
      time: 123,
      limit: 15,
    },
  },
  {
    module: 'comment_hug_list',
    query: {
      type: 0,
      sid: '101',
      uid: '42',
      cid: '555',
      page: 2,
      pageSize: 20,
    },
  },
  {
    module: 'comment_info_list',
    query: {
      type: 0,
      ids: '101, 202',
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
