-- 请勿修改此部分
CONFIG = {}

-- 雷达超速锁定功能
-- 启用后玩家可在雷达菜单中设置超速阈值，当车辆超过该速度时会自动锁定
-- 默认禁用以保持真实感
CONFIG.allow_fast_limit = true

-- 超速限制菜单排序
-- 启用后菜单将优先显示超速限制选项，然后是快速锁定开关，最后是默认菜单选项
CONFIG.fast_limit_first_in_menu = false

-- 仅锁定玩家车辆
-- 启用后雷达只会自动锁定有真实玩家驾驶的车辆速度
CONFIG.only_lock_players = false

-- 首次使用快速入门视频
-- 启用后玩家首次打开遥控器时会询问是否观看快速入门视频
CONFIG.allow_quick_start_video = true

-- 允许乘客查看
-- 启用后前排乘客可以查看雷达和车牌阅读器数据
CONFIG.allow_passenger_view = false

-- 允许乘客控制
-- 依赖CONFIG.allow_passenger_view。启用后前排乘客可以操作雷达和车牌阅读器
CONFIG.allow_passenger_control = false

-- SonoranCAD集成
-- 如果使用带WraithV2插件的SonoranCAD，请设为true
CONFIG.use_sonorancad = false

-- 默认按键绑定设置
-- 玩家可以在GTA设置->按键绑定->FiveM中修改这些绑定
CONFIG.keyDefaults =
{
    -- 遥控器按键
    remote_control = "f5",

    -- 雷达键盘锁定键
    key_lock = "l",

    -- 前雷达天线锁定/解锁键
    front_lock = "numpad8",

    -- 后雷达天线锁定/解锁键
    rear_lock = "numpad5",

    -- 前车牌阅读器锁定/解锁键
    plate_front_lock = "numpad9",

    -- 后车牌阅读器锁定/解锁键
    plate_rear_lock = "numpad6"
}

-- 操作菜单默认值设置
-- 注意：如果设置的值不在可选范围内，脚本将无法工作
CONFIG.menuDefaults =
{
    -- 是否计算并显示快速目标
    -- 选项: true 或 false
    ["fastDisplay"] = true,

    -- 每种雷达模式的灵敏度，影响天线检测车辆的距离
    -- 选项: 0.2, 0.4, 0.6, 0.8, 1.0
    ["same"] = 0.6,
    ["opp"] = 0.6,

    -- 提示音音量
    -- 选项: 0.0, 0.2, 0.4, 0.6, 0.8, 1.0
    ["beep"] = 0.6,

    -- 语音锁定确认音量
    -- 选项: 0.0, 0.2, 0.4, 0.6, 0.8, 1.0
    ["voice"] = 0.6,

    -- 车牌阅读器音量
    -- 选项: 0.0, 0.2, 0.4, 0.6, 0.8, 1.0
    ["plateAudio"] = 0.6,

    -- 速度单位
    -- 选项: mph 或 kmh
    ["speedType"] = "kmh",

    -- 自动速度锁定状态。需要CONFIG.allow_fast_limit为true
    -- 选项: true 或 false
    ["fastLock"] = false,

    -- 自动速度锁定所需的速度限制。需要CONFIG.allow_fast_limit为true
    -- 选项: 0 到 200
    ["fastLimit"] = 60
}

-- 界面显示设置
CONFIG.uiDefaults =
{
    -- UI元素默认缩放比例
    -- 选项: 0.25 - 2.5
    scale =
    {
        radar = 0.75,
        remote = 0.75,
        plateReader = 0.75
    },

    -- 安全区域大小，必须是5的倍数
    -- 选项: 0 - 100
    safezone = 20
}