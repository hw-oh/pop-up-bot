# PopUpBot - Telegram 팝업 챗봇

macOS 메뉴바에 상주하며, 글로벌 단축키로 텔레그램 봇 채팅을 팝업 윈도우로 열어주는 네이티브 앱입니다.

## 요구 사항

- macOS 14.0 (Sonoma) 이상
- Swift 5.9+
- 텔레그램 계정 (웹 로그인 필요)

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

1. 앱 실행 시 메뉴바에 말풍선 아이콘이 표시됩니다
2. 최초 실행 시 텔레그램 봇 유저네임 입력 다이얼로그가 나타납니다
3. 텔레그램 웹에 로그인합니다 (최초 1회)
4. **Option + Space** 를 누르면 팝업 채팅 윈도우가 나타납니다
5. 다시 누르면 사라집니다

## 메뉴바 메뉴

- **챗봇 열기/닫기** - 팝업 토글
- **봇 유저네임 설정** - 연결할 봇 변경
- **단축키 변경** - 글로벌 단축키 변경 (원하는 키 조합 직접 입력)
- **종료** - 앱 종료

## 단축키 변경

메뉴바 > "단축키 변경" 클릭 후, 원하는 수정키(⌘⌥⇧⌃) + 키 조합을 누르면 즉시 등록됩니다. 변경된 단축키는 앱 재시작 후에도 유지됩니다.

## 프로젝트 구조

```
Sources/PopUpBot/
├── main.swift               # 앱 진입점
├── AppDelegate.swift        # 앱 생명주기 관리
├── HotKeyManager.swift      # 글로벌 단축키 (Carbon API)
├── PopUpPanel.swift         # 플로팅 WebView 패널
└── StatusBarController.swift # 메뉴바 아이콘 + 메뉴
```
