# Security Data Model

## Asset Extension Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| deviceType | enum | Yes | camera/nvr/dvr/access_control/card_reader/electric_lock/alarm_panel/pir_sensor/door_sensor/siren/intercom/monitor/switch/other |
| resolution | string | No | 分辨率 (4MP, 8MP, 4K) |
| lensType | string | No | 镜头类型 |
| nightVision | boolean | No | 红外夜视 |
| nightVisionRange | number | No | 夜视距离 (m) |
| ptzCapable | boolean | No | 云台功能 |
| waterproof | boolean | No | 防水 |
| ipRating | string | No | IP等级 |
| audioEnabled | boolean | No | 有音频 |
| ipAddress | string | No | IP地址 |
| macAddress | string | No | MAC地址 |
| protocol | string | No | 协议 (ONVIF, RTSP) |
| storageType | enum | No | nvr/sd_card/cloud/nas |
| storageCapacity | number | No | 存储容量 (TB) |
| recordingDays | number | No | 录像保存天数 |
| doorCount | number | No | 门数量 |
| cardCapacity | number | No | 卡容量 |
| accessMethod | string[] | No | ['刷卡', '密码', '指纹', '人脸'] |
| firmwareVersion | string | No | 固件版本 |
| firmwareLastUpdate | date | No | 上次固件更新 |
| installationHeight | number | No | 安装高度 (m) |
| installationLocation | enum | No | indoor/outdoor/both |
| coverageAngle | number | No | 覆盖角度 |

## Camera Resolutions

| Resolution | Pixels | Use Case |
|-----------|--------|----------|
| 2MP | 1920×1080 | 基础监控 |
| 4MP | 2560×1440 | 标准监控 |
| 5MP | 2592×1944 | 高清监控 |
| 8MP | 3840×2160 | 4K超高清 |
| 12MP | 4000×3000 | 超高清全景 |

## Storage Calculation

| Resolution | Bitrate | 1TB Days (24h) |
|-----------|---------|----------------|
| 2MP | 4 Mbps | ~23 天 |
| 4MP | 8 Mbps | ~11 天 |
| 8MP | 16 Mbps | ~5 天 |

Formula: `days = (capacity_TB × 8 × 1024 × 1024) / (bitrate_Mbps × 3600 × 24)`
