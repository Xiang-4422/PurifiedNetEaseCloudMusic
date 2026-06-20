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
  if (request === 'qrcode') {
    return {
      async toDataURL(value) {
        return `data:image/png;base64,${Buffer.from(String(value)).toString('base64')}`
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
  if (request.endsWith('/logger.js') || request === '../util/logger.js') {
    return {
      info() {},
      warn() {},
      error() {},
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
    module: 'album_detail_dynamic',
    query: {
      id: '456',
    },
  },
  {
    module: 'album_list_style',
    query: {},
  },
  {
    module: 'album_songsaleboard',
    query: {},
  },
  {
    module: 'album_songsaleboard',
    query: {
      type: 'year',
      albumType: 1,
      year: 2025,
    },
  },
  {
    module: 'album_sub',
    query: {
      id: '456',
      t: 1,
    },
  },
  {
    module: 'album_sub',
    query: {
      id: '456',
      t: 0,
    },
  },
  {
    module: 'album_sublist',
    query: {},
  },
  {
    module: 'digitalAlbum_detail',
    query: {
      id: '456',
    },
  },
  {
    module: 'digitalAlbum_ordering',
    query: {
      id: '456',
      payment: 'alipay',
      quantity: 2,
    },
  },
  {
    module: 'digitalAlbum_purchased',
    query: {},
  },
  {
    module: 'digitalAlbum_sales',
    query: {
      ids: '456,789',
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
    module: 'lyric',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_music_detail',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_copyright_rcmd',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_copyright_rcmd',
    query: {
      songid: '202',
      id: '101',
    },
  },
  {
    module: 'song_creators',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_like',
    query: {
      id: '101',
      uid: '42',
    },
  },
  {
    module: 'song_like',
    query: {
      id: '101',
      uid: '42',
      like: 'false',
    },
  },
  {
    module: 'song_order_update',
    query: {
      pid: '888',
      ids: '101,202',
    },
  },
  {
    module: 'song_dynamic_cover',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_wiki_summary',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_chorus',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_red_count',
    query: {
      id: '101',
    },
  },
  {
    module: 'cloud_lyric_get',
    query: {
      uid: '42',
      sid: '101',
    },
  },
  {
    module: 'cloud_match',
    query: {
      uid: '42',
      sid: '101',
      asid: '202',
    },
  },
  {
    module: 'song_cloud_download',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_downlist',
    query: {},
  },
  {
    module: 'song_monthdownlist',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'song_singledownlist',
    query: {},
  },
  {
    module: 'song_purchased',
    query: {},
  },
  {
    module: 'song_lyrics_mark',
    query: {
      id: '101',
    },
  },
  {
    module: 'song_lyrics_mark_add',
    query: {
      id: '101',
      data: '[{"startTimeStamp":800}]',
    },
  },
  {
    module: 'song_lyrics_mark_del',
    query: {
      id: 'mark-1',
    },
  },
  {
    module: 'song_lyrics_mark_user_page',
    query: {},
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
    module: 'login_qr_key',
    query: {},
  },
  {
    module: 'login_qr_check',
    query: {
      key: 'qr-key',
    },
  },
  {
    module: 'captcha_sent',
    query: {
      phone: '13800000000',
    },
  },
  {
    module: 'captcha_verify',
    query: {
      phone: '13800000000',
      ctcode: '1',
      captcha: '1234',
    },
  },
  {
    module: 'cellphone_existence_check',
    query: {
      phone: '13800000000',
      countrycode: '86',
    },
  },
  {
    module: 'countries_code_list',
    query: {},
  },
  {
    module: 'verify_getQr',
    query: {
      vid: 'verify-id',
      type: 'login',
      token: 'token-1',
      evid: 'event-1',
      sign: 'sign-1',
    },
    responses: [{ status: 200, body: { code: 200, data: { qrCode: 'qr-code' } }, cookie: [] }],
  },
  {
    module: 'verify_qrcodestatus',
    query: {
      qr: 'qr-code',
    },
  },
  {
    module: 'login_status',
    query: {},
  },
  {
    module: 'login_refresh',
    query: {},
  },
  {
    module: 'logout',
    query: {},
  },
  {
    module: 'likelist',
    query: {
      uid: '42',
    },
  },
  {
    module: 'daily_signin',
    query: {},
  },
  {
    module: 'recommend_resource',
    query: {},
  },
  {
    module: 'personal_fm',
    query: {},
  },
  {
    module: 'fm_trash',
    query: {
      id: '101',
    },
  },
  {
    module: 'fm_trash',
    query: {
      id: '101',
      time: 0,
    },
  },
  {
    module: 'check_music',
    query: {
      id: '101abc',
      br: '320000abc',
    },
    responses: [{ status: 200, body: { code: 200, data: [{ code: 200 }] }, cookie: [] }],
  },
  {
    module: 'banner',
    query: {},
  },
  {
    module: 'banner',
    query: {
      type: 2,
    },
  },
  {
    module: 'homepage_dragon_ball',
    query: {},
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
    module: 'playlist_detail_rcmd_get',
    query: {
      id: '888',
    },
  },
  {
    module: 'playlist_video_recent',
    query: {
      limit: 5,
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
    module: 'playlist_create',
    query: {
      name: 'New List',
    },
  },
  {
    module: 'playlist_delete',
    query: {
      id: '888',
    },
  },
  {
    module: 'playlist_desc_update',
    query: {
      id: '888',
      desc: 'Quiet playlist',
    },
  },
  {
    module: 'playlist_highquality_tags',
    query: {},
  },
  {
    module: 'playlist_mylike',
    query: {},
  },
  {
    module: 'playlist_category_list',
    query: {},
  },
  {
    module: 'playlist_name_update',
    query: {
      id: '888',
      name: 'Renamed',
    },
  },
  {
    module: 'playlist_order_update',
    query: {
      ids: '[888,777]',
    },
  },
  {
    module: 'playlist_privacy',
    query: {
      id: '888',
      privacy: 10,
    },
  },
  {
    module: 'playlist_subscribers',
    query: {
      id: '888',
    },
  },
  {
    module: 'playlist_tags_update',
    query: {
      id: '888',
      tags: '流行;华语',
    },
  },
  {
    module: 'playlist_track_add',
    query: {
      pid: '888',
      ids: '101,202',
    },
  },
  {
    module: 'playlist_track_delete',
    query: {
      id: '888',
      ids: '101,202',
    },
  },
  {
    module: 'playlist_import_name_task_create',
    query: {
      importStarPlaylist: true,
      local: '[{"name":"Song A","artist":"Alice","album":"Album A"}]',
    },
  },
  {
    module: 'playlist_import_task_status',
    query: {
      id: 'task-1',
    },
  },
  {
    module: 'playlist_update',
    query: {
      id: '888',
      name: 'Renamed',
    },
  },
  {
    module: 'playlist_update_playcount',
    query: {
      id: '888',
    },
  },
  {
    module: 'playmode_intelligence_list',
    query: {
      id: '101',
      pid: '888',
    },
  },
  {
    module: 'playmode_intelligence_list',
    query: {
      id: '101',
      pid: '888',
      sid: '202',
      count: 0,
    },
  },
  {
    module: 'playmode_song_vector',
    query: {
      ids: '101,202',
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
    module: 'comment',
    query: {
      t: 1,
      type: 0,
      id: '101',
      content: 'nice',
    },
  },
  {
    module: 'comment',
    query: {
      t: 2,
      type: 6,
      id: 'ignored',
      threadId: 'A_EV_2_101',
      commentId: '555',
      content: 'reply',
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
    module: 'comment_album',
    query: {
      id: '123',
      limit: 10,
      offset: 20,
      before: 123456,
    },
  },
  {
    module: 'comment_dj',
    query: {
      id: '336355127',
      limit: 10,
      offset: 20,
      before: 123456,
    },
  },
  {
    module: 'comment_event',
    query: {
      threadId: 'A_EV_2_101',
      limit: 10,
      offset: 20,
      before: 123456,
    },
  },
  {
    module: 'comment_mv',
    query: {
      id: '5436712',
      limit: 10,
      offset: 20,
      before: 123456,
    },
  },
  {
    module: 'comment_video',
    query: {
      id: '89ADDE33C0AAE8EC14B99F6750DB954D',
      limit: 10,
      offset: 20,
      before: 123456,
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
    module: 'comment_report',
    query: {
      id: '101',
      cid: '555',
      reason: 'spam',
    },
  },
  {
    module: 'hug_comment',
    query: {
      type: 0,
      sid: '101',
      uid: '42',
      cid: '555',
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
    module: 'homepage_block_page',
    query: {
      refresh: true,
      cursor: 'page-2',
    },
  },
  {
    module: 'personalized_newsong',
    query: {
      limit: 12,
      areaId: 7,
    },
  },
  {
    module: 'personalized_mv',
    query: {},
  },
  {
    module: 'personalized_djprogram',
    query: {},
  },
  {
    module: 'program_recommend',
    query: {
      type: 10001,
    },
  },
  {
    module: 'program_recommend',
    query: {
      type: 10001,
      limit: 0,
      offset: 5,
    },
  },
  {
    module: 'personalized_privatecontent',
    query: {},
  },
  {
    module: 'personalized_privatecontent_list',
    query: {
      offset: 20,
      limit: 10,
    },
  },
  {
    module: 'top_song',
    query: {
      type: 7,
    },
  },
  {
    module: 'top_artists',
    query: {
      limit: 20,
      offset: 40,
    },
  },
  {
    module: 'top_album',
    query: {
      area: 'ZH',
      limit: 20,
      offset: 40,
      type: 'hot',
      year: 2025,
      month: 6,
    },
  },
  {
    module: 'album_list',
    query: {
      area: 'EA',
      limit: 20,
      offset: 40,
      type: 'new',
    },
  },
  {
    module: 'recommend_songs',
    query: {
      afresh: true,
    },
  },
  {
    module: 'recommend_songs_dislike',
    query: {
      id: '101',
    },
  },
  {
    module: 'history_recommend_songs',
    query: {
      date: '2026-06-20',
    },
  },
  {
    module: 'history_recommend_songs_detail',
    query: {},
  },
  {
    module: 'history_recommend_songs_detail',
    query: {
      date: '2026-06-20',
    },
  },
  {
    module: 'simi_artist',
    query: {
      id: '6452',
    },
  },
  {
    module: 'simi_mv',
    query: {
      mvid: '5436712',
    },
  },
  {
    module: 'simi_playlist',
    query: {
      id: '101',
    },
  },
  {
    module: 'simi_song',
    query: {
      id: '101',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'simi_user',
    query: {
      id: '101',
    },
  },
  {
    module: 'search_hot_detail',
    query: {},
  },
  {
    module: 'search_default',
    query: {},
  },
  {
    module: 'search_hot',
    query: {},
  },
  {
    module: 'search_match',
    query: {
      title: 'Song A',
      album: 'Album A',
      artist: 'Artist A',
      duration: 240000,
      md5: 'abc123',
    },
  },
  {
    module: 'search_multimatch',
    query: {
      keywords: 'hello',
    },
  },
  {
    module: 'search_suggest',
    query: {
      keywords: 'hello',
    },
  },
  {
    module: 'search_suggest',
    query: {
      keywords: 'hello',
      type: 'mobile',
    },
  },
  {
    module: 'search_suggest_pc',
    query: {
      keyword: 'hello',
    },
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
    module: 'album_detail',
    query: {
      id: '12345',
    },
  },
  {
    module: 'artist_detail',
    query: {
      id: '6452',
    },
  },
  {
    module: 'artist_desc',
    query: {
      id: '6452',
    },
  },
  {
    module: 'artist_album',
    query: {
      id: '6452',
      limit: 12,
      offset: 24,
    },
  },
  {
    module: 'artist_mv',
    query: {
      id: '6452',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'artist_top_song',
    query: {
      id: '6452',
    },
  },
  {
    module: 'artists',
    query: {
      id: '6452',
    },
  },
  {
    module: 'artist_songs',
    query: {
      id: '6452',
      order: 'time',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'artist_list',
    query: {
      initial: 'a',
      type: 2,
      area: 7,
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'artist_detail_dynamic',
    query: {
      id: '6452',
    },
  },
  {
    module: 'artist_fans',
    query: {
      id: '6452',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'artist_follow_count',
    query: {
      id: '6452',
    },
  },
  {
    module: 'artist_new_mv',
    query: {
      limit: 10,
      before: 1700000000000,
    },
  },
  {
    module: 'artist_new_song',
    query: {
      limit: 10,
      before: 1700000000000,
    },
  },
  {
    module: 'artist_sub',
    query: {
      id: '6452',
      t: 1,
    },
  },
  {
    module: 'artist_sub',
    query: {
      id: '6452',
      t: 0,
    },
  },
  {
    module: 'artist_sublist',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'artist_video',
    query: {
      id: '6452',
      size: 20,
      cursor: 'cursor-1',
      order: 1,
    },
  },
  {
    module: 'ugc_album_get',
    query: {
      id: '100',
    },
  },
  {
    module: 'ugc_artist_get',
    query: {
      id: '200',
    },
  },
  {
    module: 'ugc_artist_search',
    query: {
      keyword: 'artist',
      limit: 20,
    },
  },
  {
    module: 'ugc_detail',
    query: {
      auditStatus: 5,
      limit: 20,
      offset: 10,
      order: 'asc',
      sortBy: 'updateTime',
      type: 3,
    },
  },
  {
    module: 'ugc_mv_get',
    query: {
      id: '300',
    },
  },
  {
    module: 'ugc_song_get',
    query: {
      id: '400',
    },
  },
  {
    module: 'ugc_user_devote',
    query: {},
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
    module: 'user_account',
    query: {},
  },
  {
    module: 'user_subcount',
    query: {},
  },
  {
    module: 'user_level',
    query: {},
  },
  {
    module: 'user_binding',
    query: {
      uid: '32953014',
    },
  },
  {
    module: 'user_bindingcellphone',
    query: {
      phone: '13000000000',
      captcha: '1234',
      password: 'secret',
    },
  },
  {
    module: 'user_cloud',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'user_cloud_detail',
    query: {
      id: '101, 202',
    },
  },
  {
    module: 'user_cloud_del',
    query: {
      id: '101',
    },
  },
  {
    module: 'user_record',
    query: {
      uid: '32953014',
      type: 1,
    },
  },
  {
    module: 'user_follows',
    query: {
      uid: '32953014',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'user_followeds',
    query: {
      uid: '32953014',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'user_dj',
    query: {
      uid: '32953014',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'user_event',
    query: {
      uid: '32953014',
      lasttime: 123456,
      limit: 10,
    },
  },
  {
    module: 'user_audio',
    query: {
      uid: '32953014',
    },
  },
  {
    module: 'user_comment_history',
    query: {
      uid: '32953014',
      limit: 10,
      time: 123456,
    },
  },
  {
    module: 'user_playlist_collect',
    query: {
      uid: '32953014',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'user_playlist_create',
    query: {
      uid: '32953014',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'user_medal',
    query: {
      uid: '32953014',
    },
  },
  {
    module: 'user_mutualfollow_get',
    query: {
      uid: '32953014',
    },
  },
  {
    module: 'user_replacephone',
    query: {
      phone: '13000000000',
      captcha: '1234',
      oldcaptcha: '5678',
    },
  },
  {
    module: 'user_social_status',
    query: {
      uid: '32953014',
    },
  },
  {
    module: 'user_social_status_edit',
    query: {
      type: 'music',
      iconUrl: 'https://example.test/icon.png',
      content: 'listening',
      actionUrl: 'orpheus://song/1',
    },
  },
  {
    module: 'user_social_status_rcmd',
    query: {},
  },
  {
    module: 'user_social_status_support',
    query: {},
  },
  {
    module: 'user_update',
    query: {
      birthday: 1700000000000,
      city: 110101,
      gender: 1,
      nickname: 'nick',
      province: 110000,
      signature: 'hello',
    },
  },
  {
    module: 'musician_cloudbean',
    query: {},
  },
  {
    module: 'musician_cloudbean_obtain',
    query: {
      id: 'mission-1',
      period: 7,
    },
  },
  {
    module: 'musician_data_overview',
    query: {},
  },
  {
    module: 'musician_play_trend',
    query: {
      startTime: 1700000000000,
      endTime: 1700604800000,
    },
  },
  {
    module: 'musician_sign',
    query: {},
  },
  {
    module: 'musician_tasks',
    query: {},
  },
  {
    module: 'musician_tasks_new',
    query: {},
  },
  {
    module: 'musician_vip_tasks',
    query: {},
  },
  {
    module: 'mv_all',
    query: {
      area: '内地',
      type: '官方版',
      order: '最新',
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'mv_detail',
    query: {
      mvid: '5436712',
    },
  },
  {
    module: 'mv_detail_info',
    query: {
      mvid: '5436712',
    },
  },
  {
    module: 'mv_exclusive_rcmd',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'mv_first',
    query: {
      area: '内地',
      limit: 10,
    },
  },
  {
    module: 'mv_sub',
    query: {
      mvid: '5436712',
      t: 1,
    },
  },
  {
    module: 'mv_sub',
    query: {
      mvid: '5436712',
      t: 0,
    },
  },
  {
    module: 'mv_sublist',
    query: {
      limit: 10,
      offset: 20,
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
    module: 'video_category_list',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'video_detail',
    query: {
      id: '89ADDE33C0AAE8EC14B99F6750DB954D',
    },
  },
  {
    module: 'video_detail_info',
    query: {
      vid: '89ADDE33C0AAE8EC14B99F6750DB954D',
    },
  },
  {
    module: 'video_group',
    query: {
      id: 'group-1',
      offset: 20,
    },
  },
  {
    module: 'video_group_list',
    query: {},
  },
  {
    module: 'video_sub',
    query: {
      id: '89ADDE33C0AAE8EC14B99F6750DB954D',
      t: 1,
    },
  },
  {
    module: 'video_sub',
    query: {
      id: '89ADDE33C0AAE8EC14B99F6750DB954D',
      t: 0,
    },
  },
  {
    module: 'video_timeline_all',
    query: {
      offset: 20,
    },
  },
  {
    module: 'video_timeline_recommend',
    query: {
      offset: 20,
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
    module: 'record_recent_album',
    query: {
      limit: 10,
    },
  },
  {
    module: 'record_recent_dj',
    query: {
      limit: 10,
    },
  },
  {
    module: 'record_recent_playlist',
    query: {
      limit: 10,
    },
  },
  {
    module: 'record_recent_voice',
    query: {
      limit: 10,
    },
  },
  {
    module: 'recent_listen_list',
    query: {
      limit: 5,
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
    module: 'chart_detail',
    query: {
      chartCode: 'weekly',
      targetId: '19723756',
      targetType: 'song',
    },
  },
  {
    module: 'chart_song_detail',
    query: {
      chartCode: 'weekly',
      targetId: '19723756',
      targetType: 'song',
    },
  },
  {
    module: 'top_list',
    query: {
      id: '3779629',
    },
  },
  {
    module: 'broadcast_category_region_get',
    query: {},
  },
  {
    module: 'broadcast_channel_collect_list',
    query: {
      limit: 50,
    },
  },
  {
    module: 'broadcast_channel_currentinfo',
    query: {
      id: '5',
    },
  },
  {
    module: 'broadcast_channel_list',
    query: {},
  },
  {
    module: 'broadcast_sub',
    query: {
      id: '5',
      t: 1,
    },
  },
  {
    module: 'radio_sport_get',
    query: {},
  },
  {
    module: 'sati_resource_list',
    query: {
      tag: 'rain',
    },
  },
  {
    module: 'sati_resource_list_more',
    query: {
      id: '167003',
    },
  },
  {
    module: 'sati_resource_sub',
    query: {
      id: '167003',
      cancel: true,
    },
  },
  {
    module: 'sati_resource_sub_list',
    query: {},
  },
  {
    module: 'sati_tag_list',
    query: {},
  },
  {
    module: 'sati_timescene_resources_get',
    query: {},
  },
  {
    module: 'listen_data_realtime_report',
    query: {
      type: 'month',
    },
  },
  {
    module: 'listen_data_report',
    query: {
      type: 'year',
      endTime: 1767110400000,
    },
  },
  {
    module: 'listen_data_today_song',
    query: {},
  },
  {
    module: 'listen_data_total',
    query: {},
  },
  {
    module: 'listen_data_year_report',
    query: {},
  },
  {
    module: 'listentogether_accept',
    query: {
      roomId: 'room-1',
      inviterId: '42',
    },
  },
  {
    module: 'listentogether_end',
    query: {
      roomId: 'room-1',
    },
  },
  {
    module: 'listentogether_heatbeat',
    query: {
      roomId: 'room-1',
      songId: '101',
      playStatus: 1,
      progress: 120000,
    },
  },
  {
    module: 'listentogether_play_command',
    query: {
      roomId: 'room-1',
      commandType: 'play',
      playStatus: 1,
      formerSongId: '101',
      targetSongId: '202',
      clientSeq: 7,
    },
  },
  {
    module: 'listentogether_room_check',
    query: {
      roomId: 'room-1',
    },
  },
  {
    module: 'listentogether_room_create',
    query: {},
  },
  {
    module: 'listentogether_status',
    query: {},
  },
  {
    module: 'listentogether_sync_list_command',
    query: {
      roomId: 'room-1',
      commandType: 'sync',
      userId: '42',
      version: 3,
      randomList: '101,202',
      displayList: '202,101',
    },
  },
  {
    module: 'listentogether_sync_playlist_get',
    query: {
      roomId: 'room-1',
    },
  },
  {
    module: 'vip_growthpoint',
    query: {},
  },
  {
    module: 'vip_growthpoint_details',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'vip_growthpoint_get',
    query: {
      ids: 'task-1,task-2',
    },
  },
  {
    module: 'vip_info',
    query: {
      uid: '42',
    },
  },
  {
    module: 'vip_info_v2',
    query: {
      uid: '42',
    },
  },
  {
    module: 'vip_sign',
    query: {},
  },
  {
    module: 'vip_sign_detail',
    query: {
      timestamp: 1767110400000,
    },
  },
  {
    module: 'vip_sign_info',
    query: {},
  },
  {
    module: 'vip_tasks',
    query: {},
  },
  {
    module: 'vip_timemachine',
    query: {
      startTime: 1,
      endTime: 2,
      limit: 30,
    },
  },
  {
    module: 'yunbei',
    query: {},
  },
  {
    module: 'yunbei_expense',
    query: {
      limit: 5,
      offset: 10,
    },
  },
  {
    module: 'yunbei_info',
    query: {},
  },
  {
    module: 'yunbei_rcmd_song',
    query: {
      id: '101',
      reason: '值得一听',
      yunbeiNum: 20,
    },
  },
  {
    module: 'yunbei_rcmd_song_history',
    query: {
      size: 10,
      cursor: 'cursor-1',
    },
  },
  {
    module: 'yunbei_receipt',
    query: {
      limit: 5,
      offset: 10,
    },
  },
  {
    module: 'yunbei_sign',
    query: {},
  },
  {
    module: 'yunbei_task_finish',
    query: {
      userTaskId: 'task-1',
      depositCode: 'deposit-1',
    },
  },
  {
    module: 'yunbei_tasks',
    query: {},
  },
  {
    module: 'yunbei_tasks_todo',
    query: {},
  },
  {
    module: 'yunbei_today',
    query: {},
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
    module: 'djRadio_top',
    query: {
      djRadioId: '336355127',
      sortIndex: 2,
      dataGapDays: 30,
      dataType: 3,
    },
  },
  {
    module: 'dj_banner',
    query: {},
  },
  {
    module: 'dj_category_excludehot',
    query: {},
  },
  {
    module: 'dj_category_recommend',
    query: {},
  },
  {
    module: 'dj_catelist',
    query: {},
  },
  {
    module: 'dj_detail',
    query: {
      rid: '336355127',
    },
  },
  {
    module: 'dj_difm_all_style_channel',
    query: {
      sources: '[0,1]',
    },
  },
  {
    module: 'dj_difm_channel_subscribe',
    query: {
      id: 'channel-1',
    },
  },
  {
    module: 'dj_difm_channel_unsubscribe',
    query: {
      id: 'channel-1',
    },
  },
  {
    module: 'dj_difm_playing_tracks_list',
    query: {
      channelId: 'channel-1',
      limit: 8,
      source: 1,
    },
  },
  {
    module: 'dj_difm_subscribe_channels_get',
    query: {
      sources: '[0,1]',
    },
  },
  {
    module: 'dj_hot',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'dj_paygift',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'dj_personalize_recommend',
    query: {
      limit: 4,
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
    module: 'dj_program_toplist',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'dj_program_toplist_hours',
    query: {
      limit: 10,
    },
  },
  {
    module: 'dj_radio_hot',
    query: {
      cateId: 10001,
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'dj_recommend',
    query: {},
  },
  {
    module: 'dj_recommend_type',
    query: {
      type: 10001,
    },
  },
  {
    module: 'dj_sub',
    query: {
      rid: '336355127',
      t: 1,
    },
  },
  {
    module: 'dj_sublist',
    query: {
      limit: 10,
      offset: 20,
    },
  },
  {
    module: 'dj_subscriber',
    query: {
      id: '336355127',
      time: 123456,
      limit: 10,
    },
  },
  {
    module: 'dj_today_perfered',
    query: {
      page: 2,
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
    module: 'dj_toplist_pay',
    query: {
      limit: 10,
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
