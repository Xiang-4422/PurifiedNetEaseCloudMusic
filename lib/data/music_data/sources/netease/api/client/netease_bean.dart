// ignore_for_file: constant_identifier_names

export '../models/dj/bean.dart';
export '../models/event/bean.dart';
export '../models/login/bean.dart';
export '../models/play/bean.dart';
export '../models/search/bean.dart';
export '../models/uncategorized/bean.dart';
export '../models/user/bean.dart';

/// 未知或未归类错误码。
const int RET_CODE_UNKNOW = -233;

/// 网易云接口通用成功状态码。
const int RET_CODE_OK = 200;

/// 无权限或操作不允许状态码。
const int RET_CODE_NO_PERMISSION = -2;

/// 关注等接口的成功状态码。
const int RET_CODE_OK_FOLLOW = 201;
// title: "风险提示",subtitle: "请您尝试切换网络或设备再尝试操作哦~",buttonMsg: "查看详情",buttonUrl: "http://163.lu/EmUzy2"
/// 账号或请求触发风险提示状态码。
const int RET_CODE_RISK_WARNING = 250;

/// 风控作弊状态码。
const int RET_CODE_CHEATING = -460;

/// 未登录或登录态失效状态码。
const int RET_CODE_NEED_LOGIN = 301;

/// 参数非法状态码。
const int RET_CODE_ILLEGAL = 400;

/// 请求非法状态码。
const int RET_CODE_ILLEGAL_REQUEST = 403;

/// 请求资源不存在状态码。
const int RET_CODE_REQUEST_NOT_FOUNT = 404;
//用户已初始化
/// 用户已经初始化状态码。
const int RET_CODE_HAS_INIT = 408;

/// 账号不存在状态码。
const int RET_CODE_ACCOUNT_NOT_FOUND = 501;

/// 用户资料更新字段被占用状态码。
const int RET_CODE_UPDATE_PROFILE_OCCUPY = 505;

/// 验证码校验失败状态码。
const int RET_CODE_CAPTCHA_VERIFY_FAIL = 503;

/// 验证码校验过于频繁状态码。
const int RET_CODE_CAPTCHA_VERIFY_FREQUENTLY = 405;

//未付费歌曲无法收藏
/// 未付费歌曲不可收藏状态码。
const int RET_CODE_UNPAID = 512;

/// SDK 归一化后的接口返回码分类。
enum RetCode {
  /// 请求成功。
  Ok,

  /// 需要登录。
  NeedLogin,

  /// 参数非法。
  IllegalArgument,

  /// 请求非法。
  IllegalRequest,

  /// 请求资源不存在。
  RequestNotFount,

  /// 未知状态。
  UnKnow
}

/// 将网易云接口数值状态码转换为 SDK 内部状态枚举。
RetCode valueOfCode(int code) {
  switch (code) {
    case RET_CODE_OK:
      return RetCode.Ok;
    case RET_CODE_NEED_LOGIN:
      return RetCode.NeedLogin;
    case RET_CODE_ILLEGAL:
      return RetCode.IllegalArgument;
    case RET_CODE_ILLEGAL_REQUEST:
      return RetCode.IllegalRequest;
    case RET_CODE_REQUEST_NOT_FOUNT:
      return RetCode.RequestNotFount;
  }
  return RetCode.UnKnow;
}
