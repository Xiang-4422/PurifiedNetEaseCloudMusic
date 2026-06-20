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
  if (request === '@neteasecloudmusicapienhanced/unblockmusic-utils') {
    return {
      async matchID() {
        return { data: {} }
      },
    }
  }
  if (request === 'axios') {
    return {
      default: async (config) => {
        if (config.url && config.url.includes('wanproxy.127.net/lbs')) {
          return { data: { upload: ['https://upload.test'] } }
        }
        if (config.url && config.url.includes('?uploads')) {
          return {
            data: '<InitiateMultipartUploadResult><UploadId>upload-id</UploadId></InitiateMultipartUploadResult>',
          }
        }
        if (config.method === 'put') {
          return { data: '', headers: { etag: 'etag-1' } }
        }
        return { data: '', headers: {} }
      },
    }
  }
  if (request === 'xml2js') {
    return {
      Parser: class {
        async parseStringPromise() {
          return {
            InitiateMultipartUploadResult: {
              UploadId: ['upload-id'],
            },
          }
        }
      },
    }
  }
  if (request === 'dotenv') {
    return {
      config() {
        return {}
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
  {
    module: 'album_new',
    query: {
      area: 'ZH',
      limit: 12,
      offset: 24,
    },
  },
  {
    module: 'album_newest',
    query: {},
  },
  {
    module: 'artist_detail',
    query: {
      id: '6452',
    },
  },
  {
    module: 'artist_detail_dynamic',
    query: {
      id: '6452',
    },
  },
  {
    module: 'user_detail',
    query: {
      uid: '32953014',
    },
  },
  {
    module: 'user_detail_new',
    query: {
      uid: '32953014',
    },
  },
  {
    module: 'mv_url',
    query: {
      id: '5436712',
      r: 720,
    },
  },
  {
    module: 'video_url',
    query: {
      id: '89ADDE33C0AAE8EC14B99F6750DB954D',
      res: 720,
    },
  },
  {
    module: 'record_recent_song',
    query: {
      limit: 30,
    },
  },
  {
    module: 'record_recent_video',
    query: {
      limit: 20,
    },
  },
  {
    module: 'song_download_url',
    query: {
      id: '101',
      br: '320000',
    },
  },
  {
    module: 'song_download_url_v1',
    query: {
      id: '101',
      level: 'lossless',
    },
  },
  {
    module: 'song_like_check',
    query: {
      ids: '[101,202]',
    },
  },
  {
    module: 'user_follow_mixed',
    query: {
      size: 40,
      cursor: 100,
      scene: 1,
    },
  },
  {
    module: 'playlist_catlist',
    query: {},
  },
  {
    module: 'toplist',
    query: {},
  },
  {
    module: 'toplist_detail',
    query: {},
  },
  {
    module: 'toplist_detail_v2',
    query: {},
  },
  {
    module: 'toplist_artist',
    query: {
      type: 2,
    },
  },
  {
    module: 'top_mv',
    query: {
      area: '内地',
      limit: 20,
      offset: 40,
    },
  },
  {
    module: 'dj_program',
    query: {
      rid: '336355127',
      limit: 10,
      offset: 20,
      asc: 'true',
    },
  },
  {
    module: 'dj_program_detail',
    query: {
      id: '2069983500',
    },
  },
  {
    module: 'dj_toplist',
    query: {
      type: 'hot',
      limit: 25,
      offset: 50,
    },
  },
  {
    module: 'dj_toplist_hours',
    query: {
      limit: 10,
    },
  },
  {
    module: 'dj_toplist_newcomer',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'dj_toplist_popular',
    query: {
      limit: 10,
    },
  },
  {
    module: 'song_url_v1',
    query: {
      id: '101',
      level: 'sky',
      source: 'qq,kugou,kuwo',
    },
  },
  {
    module: 'vip_sign_history',
    query: {},
  },
  {
    module: 'vip_tasks_v1',
    query: {
      id: '42',
      realIP: '1.2.3.4',
      ua: 'unit-test',
      domain: 'https://example.test',
      checkToken: true,
      proxy: 'http://127.0.0.1:8080',
      cookie: { MUSIC_U: 'token' },
    },
  },
  {
    module: 'song_url_v1_302',
    query: {
      id: '101',
      level: 'sky',
    },
    captureRequests: true,
    responses: [
      { status: 200, body: { data: [{ url: null }] }, cookie: [] },
      {
        status: 200,
        body: { data: [{ url: 'https://audio.test/player.flac' }] },
        cookie: [],
      },
    ],
  },
  {
    module: 'playlist_track_all',
    query: {
      id: '888',
      s: 4,
      limit: '2',
      offset: '1',
    },
    captureRequests: true,
    responses: [
      {
        status: 200,
        body: {
          playlist: {
            trackIds: [{ id: 100 }, { id: 101 }, { id: 102 }, { id: 103 }],
          },
        },
        cookie: [],
      },
      { status: 200, body: { songs: [{ id: 101 }, { id: 102 }] }, cookie: [] },
    ],
  },
  {
    module: 'scrobble',
    query: {
      id: '100',
      sourceid: '200',
      time: 30,
      cookie: { MUSIC_U: 'token' },
      domain: 'https://ignored.test',
    },
    captureRequests: true,
    responses: [
      { status: 200, body: { ok: 'startplay' }, cookie: [] },
      { status: 200, body: { ok: 'play' }, cookie: [] },
    ],
  },
  {
    module: 'cloud_import',
    query: {
      md5: 'abc',
      bitrate: 320000,
      fileSize: 12345,
      song: 'Imported Song',
      fileType: 'flac',
    },
    captureRequests: true,
    responses: [
      { status: 200, body: { data: [{ songId: 456 }] }, cookie: [] },
      { status: 200, body: { code: 200, imported: true }, cookie: [] },
    ],
  },
  {
    module: 'cloud_upload_token',
    query: {
      md5: 'abc',
      fileSize: 12345,
      filename: 'My Song.flac',
    },
    captureRequests: true,
    responses: [
      { status: 200, body: { needUpload: true, songId: 456 }, cookie: [] },
      {
        status: 200,
        body: {
          result: {
            objectKey: 'cloud/object key',
            token: 'cloud-token',
            resourceId: 'resource-1',
          },
        },
        cookie: [],
      },
    ],
  },
  {
    module: 'avatar_upload',
    query: {
      filename: 'avatar.jpg',
      bytes: [1, 2, 3],
      imgFile: {
        name: 'avatar.jpg',
        mimetype: 'image/jpeg',
        data: [1, 2, 3],
      },
    },
    captureRequests: true,
    responses: [
      {
        status: 200,
        body: {
          result: {
            objectKey: 'object-key',
            token: 'upload-token',
            docId: 123,
          },
        },
        cookie: [],
      },
      { status: 200, body: { code: 200 }, cookie: [] },
    ],
  },
  {
    module: 'playlist_cover_update',
    query: {
      id: '888',
      filename: 'cover.jpg',
      bytes: [1, 2, 3],
      imgFile: {
        name: 'cover.jpg',
        mimetype: 'image/jpeg',
        data: [1, 2, 3],
      },
    },
    captureRequests: true,
    responses: [
      {
        status: 200,
        body: {
          result: {
            objectKey: 'object-key',
            token: 'upload-token',
            docId: 123,
          },
        },
        cookie: [],
      },
      { status: 200, body: { code: 200 }, cookie: [] },
    ],
  },
  {
    module: 'cloud_upload_complete',
    query: {
      songId: 456,
      resourceId: 'resource-1',
      md5: 'abc',
      filename: 'My Song.flac',
    },
    captureRequests: true,
    responses: [
      { status: 200, body: { code: 200, songId: 789 }, cookie: [] },
      { status: 200, body: { code: 200, published: true }, cookie: [] },
    ],
  },
  {
    module: 'voice_upload',
    query: {
      songFile: {
        name: 'My Voice.mp3',
        mimetype: 'audio/mpeg',
        size: 3,
        data: [1, 2, 3],
      },
      autoPublish: '1',
      privacy: 1,
      composedSongs: '100,200',
      voiceListId: 'list-1',
      categoryId: 'cat-1',
    },
    captureRequests: true,
    responses: [
      {
        status: 200,
        body: {
          result: {
            objectKey: 'voice/object-key',
            token: 'voice-token',
            docId: 321,
          },
        },
        cookie: [],
      },
      { status: 200, body: { code: 200, preCheck: true }, cookie: [] },
      { status: 200, body: { data: { voiceId: 999 } }, cookie: [] },
    ],
  },
  {
    module: 'playlist_tracks',
    query: {
      op: 'add',
      pid: '888',
      tracks: '101,202',
    },
    captureRequests: true,
    responses: [
      { reject: true, status: 500, body: { code: 512 }, cookie: [] },
      { status: 200, body: { code: 200, retry: true }, cookie: [] },
    ],
  },
]

async function captureFixture(fixture) {
  const modulePath = path.join(upstreamRoot, 'module', `${fixture.module}.js`)
  const upstreamModule = require(modulePath)
  const query = JSON.parse(JSON.stringify(fixture.query))
  let captured = null
  const requests = []
  let requestIndex = 0
  const request = (uri, data, options) => {
    captured = { uri, data, options }
    requests.push(captured)
    const response =
      fixture.responses && requestIndex < fixture.responses.length
        ? fixture.responses[requestIndex]
        : { status: 200, body: { code: 200, data: [] }, cookie: [] }
    requestIndex += 1
    if (response.reject) {
      return Promise.reject(
        JSON.parse(
          JSON.stringify({
            status: response.status || 500,
            body: response.body || {},
            cookie: response.cookie || [],
          }),
        ),
      )
    }
    return Promise.resolve(JSON.parse(JSON.stringify(response)))
  }

  await upstreamModule(query, request)
  if (!captured) {
    throw new Error(`Module ${fixture.module} did not call request`)
  }
  const result = {
    module: fixture.module,
    query: fixture.query,
    ...captured,
  }
  if (fixture.captureRequests) {
    result.requests = requests
  }
  return result
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
