# PopUpBot

[![English](https://img.shields.io/badge/lang-English-blue)](README.md)

macOS 메뉴바에 상주하며, 글로벌 단축키로 텔레그램 봇 채팅을 팝업 윈도우로 열어주는 네이티브 앱입니다.

## 요구 사항

- macOS 14.0 (Sonoma) 이상
- Swift 5.9+
- 텔레그램 계정 (최초 실행 시 웹 로그인 필요)

## 빌드 & 실행

### 빠른 실행 (개발용)

```bash
swift build -c release
.build/release/PopUpBot
```

### .app 번들 생성

```bash
./Scripts/build-app.sh
open build/PopUpBot.app
```

### 설치

```bash
cp -r build/PopUpBot.app ~/Applications/
```

## 사용법

1. 앱 실행 시 메뉴바에 말풍선 아이콘이 표시됩니다.
2. 최초 실행 시 봇 API 토큰과 유저네임을 입력하는 설정 창이 나타납니다.
3. 텔레그램 웹에 로그인합니다 (최초 1회).
4. **Option + Space** 를 누르면 팝업 채팅 윈도우가 나타납니다.

## 기능

- **글로벌 단축키** — 설정 가능한 단축키 (기본 `Option + Space`)로 패널 토글.
- **플로팅 패널** — 항상 최상위, 크기 조절 및 드래그 가능한 윈도우. 좌측 하단에 위치.
- **네이티브 알림** — 패널이 숨겨져 있을 때 새 메시지가 오면 macOS 알림으로 표시.
- **글자 크기 조절** — `⌘+` / `⌘-` / `⌘0`으로 조절. 세션 간 유지.
- **설정 창** — 봇 토큰 및 유저네임을 전용 UI에서 설정.
- **패널 닫기** — `Esc` 또는 `⌘W`로 닫기. 외부 클릭 시에도 자동 숨김.

## 메뉴바 메뉴

- **챗봇 열기/닫기** — 팝업 토글
- **글자 크기** — 크게 / 작게 / 기본 크기
- **단축키 변경** — 새 글로벌 단축키 녹화
- **설정…** — 봇 토큰 & 유저네임 설정
- **종료** — 앱 종료

## 프로젝트 구조

```
Sources/PopUpBot/
├── main.swift                # 앱 진입점
├── AppDelegate.swift         # 앱 생명주기 관리
├── HotKeyManager.swift       # 글로벌 단축키 (Carbon API)
├── PopUpPanel.swift          # 플로팅 WebView 패널 & 알림
├── SettingsWindow.swift      # 봇 자격증명 설정 UI
└── StatusBarController.swift # 메뉴바 아이콘 & 메뉴
```

## 라이선스

MIT
