# HangulSync

![HangulSync](assets/icon-256.png)

[English](docs/README.en.md) · [포크 저장소](https://github.com/entelecheia/HangulSync) · [upstream](https://github.com/catgarret/HangulSync)

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

HangulSync는 원격 데스크탑에서 한글 자소 분리(`ㅎㅏㄴㄱㅡㄹ`)를 줄이는 macOS 메뉴바 앱입니다. 두 Mac의 선택된 입력 소스를 동기화합니다.

이 저장소는 [catgarret/HangulSync](https://github.com/catgarret/HangulSync)의 relay-only fork입니다. 이 fork는 직접 연결을 사용하지 않고, 명시적인 초대와 ntfy.sh 종단간 암호화 릴레이로 페어링하고 동기화합니다.

`docs/README.*.md`의 다른 언어 파일은 upstream의 legacy 문서입니다. 직접 연결 방식 등 upstream 동작을 설명할 수 있으므로 이 fork의 사용법으로 보지 마세요.

## 동작 방식

- 입력 소스 변경을 양방향으로 전달합니다.
- 상대 Mac에 같은 입력 소스가 있으면 그대로 선택하고, 없으면 같은 언어의 입력 소스로 대체합니다.
- 모든 직접 TCP 연결을 비활성화했습니다. Bonjour 및 Tailscale 탐지와 재연결도 사용하지 않으며, 자동 탐지 컨트롤은 UI에 표시되지 않습니다.
- 페어링과 동기화는 `https://ntfy.sh` 릴레이를 통해 이루어집니다. 페이로드는 두 Mac 사이에서 종단간 암호화됩니다.
- 이 방식에는 인터넷 연결과 ntfy.sh 가용성이 필요합니다. 지연 시간은 네트워크 상태에 따라 달라집니다. ntfy.sh는 연결, 타이밍, 토픽, 암호문 관련 메타데이터를 볼 수 있습니다.
- 앱의 기기 identity 키는 macOS 로그인 Keychain에 저장합니다.

## 설치

이 fork에는 아직 내려받을 수 있는 릴리스가 없습니다. [포크 Releases 페이지](https://github.com/entelecheia/HangulSync/releases)는 향후 패키지를 위한 곳이며, 현재는 두 Mac에서 소스에서 빌드해 설치합니다.

```bash
git clone https://github.com/entelecheia/HangulSync.git
cd HangulSync
./install.sh
```

macOS 13 이상과 Xcode Command Line Tools가 필요합니다 (`xcode-select --install`). 이 fork는 직접 네트워크를 사용하지 않으므로 로컬 네트워크 권한을 허용할 필요가 없습니다.

## 첫 페어링

자동 탐지는 제공하지 않습니다. 두 Mac에서 앱을 실행한 뒤 초대 코드로 페어링하세요.

1. 한쪽 Mac에서 **초대 코드 만들기**를 누르고 코드를 복사합니다.
2. 다른 Mac에서 **초대 코드 입력**을 누르고 2분 안에 코드를 붙여 넣습니다.
3. 양쪽에 같은 6자리 확인 코드가 표시되는지 확인하고 양쪽에서 **승인**합니다.
4. 이후 자동 재연결을 원하면 **이 기기를 계속 신뢰**를 켭니다.
5. 두 Mac의 설정에서 **로그인 시 자동 실행**을 켜면 로그인 후 앱이 자동으로 시작됩니다.

초대 코드를 붙여 넣은 뒤 페어링 메시지는 ntfy.sh를 통해 전달되며, 두 Mac 사이에서 암호화됩니다. macOS가 Keychain 접근을 요청하면 앱 이름이 HangulSync인지 확인하고 시스템 대화상자에서만 로그인 암호를 입력하세요. HangulSync 창에는 암호를 입력하지 않습니다.

## 원격 세션 옵션

**원격 접속 중에만 동기화**는 기본으로 켜져 있습니다. 이 옵션은 Jump Desktop, 화면 공유, Screens, TeamViewer, AnyDesk, RustDesk 등 지원되는 원격 데스크탑 뷰어 앱이 실행 중이면 동기화를 허용합니다. 실제 원격 연결 여부나 해당 앱이 전면(frontmost)인지 여부는 확인하지 않습니다. 항상 동기화하려면 이 옵션을 끄세요.

## 메뉴바 아이콘

| 표시 | 의미 |
|---|---|
| `⇄한` / `⇄A` | 동기화 중 (현재 입력: 한글/영문) |
| `⏸한` / `⏸A` | 일시정지 |
| 흐린 아이콘 | 대기 중 (원격 데스크탑 뷰어 앱이 실행되지 않음) |

메뉴에서 페어링된 Mac 수를 확인하고 동기화를 일시정지하거나 재개할 수 있습니다.

## 검증한 범위 (2026-09-04)

- 테스트 16개 통과
- 실제 ntfy.sh를 사용한 임시 identity 페어링 및 암호화 메시지 smoke test 통과
- 두 Mac 입력 소스 동기화, 앱 재시작 후 재연결, Jump Desktop 재연결 통과
- 물리 키보드 한글 조합은 확인하지 않음. 합성 ASCII 입력을 UI 자동화하는 동안 입력 소스가 바뀌어 이 시나리오의 결과를 신뢰하기 어렵습니다.

## 라이선스

MIT © [dongri.me](https://dongri.me/). 이 fork는 [catgarret/HangulSync](https://github.com/catgarret/HangulSync)의 upstream MIT 라이선스를 유지합니다.
