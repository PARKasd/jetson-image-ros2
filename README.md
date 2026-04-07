# Jetson Orin Nano 커스텀 이미지

Jetson Orin Nano Dev Kit용 커스텀 rootfs 이미지 빌드 도구입니다.

## 포함된 소프트웨어

| 소프트웨어 | 설명 |
|---|---|
| **ROS2 Humble** (22.04) / **ROS2 Kilted** (24.04) | 로봇 운영 체제 |
| **Terminator** | 터미널 에뮬레이터 |
| **NoMachine** | 원격 데스크톱 |
| **Antigravity** | Google의 Gemini 탑재 VS Code |
| **Claude Code** | Anthropic CLI |
| **Zsh + Oh My Zsh** | zsh-syntax-highlighting, zsh-autosuggestions 플러그인 포함 |

## 사전 요구 사항

```bash
sudo apt update && sudo apt install -y podman qemu-user-static
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin
```

## 빌드 방법

### Ubuntu 22.04 + ROS2 Humble

```bash
just build-jetson-rootfs 22.04
just build-jetson-image -b jetson-orin-nano -d USB -l 36
```

### Ubuntu 24.04 + ROS2 Kilted

```bash
just build-jetson-rootfs 24.04
just build-jetson-image -b jetson-orin-nano -d USB -l 36
```

> `-d USB`는 NVMe SSD를 포함한 비-SD 저장장치에 사용합니다.

## 플래시 방법

### 방법 1: NVMe SSD에 직접 플래시 (권장)

NVMe SSD를 USB 인클로저에 넣고 호스트 PC에 연결한 후:

```bash
# 장치 경로 확인
lsblk

# 플래시 (sdX를 실제 장치 경로로 변경)
just flash-jetson-image jetson.img /dev/sdX
```

플래시 완료 후 SSD를 Jetson Orin Nano에 장착하고 부팅합니다.

### 방법 2: NVIDIA L4T flash.sh 사용

`just build-jetson-rootfs`로 생성된 `rootfs/` 디렉토리를 NVIDIA L4T 도구와 함께 사용할 수도 있습니다:

```bash
# L4T BSP의 rootfs를 커스텀 rootfs로 교체
sudo cp -a ~/jetson-image/rootfs/* /path/to/Linux_for_Tegra/rootfs/
cd /path/to/Linux_for_Tegra
sudo ./apply_binaries.sh

# Jetson을 리커버리 모드로 진입 (리커버리 버튼 + 전원, USB 연결)
sudo ./flash.sh jetson-orin-nano-devkit nvme0n1p1
```

## 기본 계정

- **사용자명:** `jetson`
- **비밀번호:** `jetson`
- **기본 쉘:** zsh (Oh My Zsh)
- **시간대:** Asia/Seoul

## 첫 부팅 후 설정

```bash
# rosdep 업데이트
rosdep update

# Claude Code API 키 설정
export ANTHROPIC_API_KEY=your_key_here
```

## 빌드 초기화

```bash
just clean
```
