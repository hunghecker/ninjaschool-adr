# Ninja School Offline v1.25.42 — APK Port Kit

Bộ này dùng **J2ME Loader** làm runtime Android và đưa trực tiếp JAR đã vá vào flavor `midlet` của J2ME Loader.

## Game được nhúng

- MIDlet: `GameMidlet`
- Phiên bản: `1.25.42`
- J2ME: MIDP 2.0 / CLDC 1.1
- Bản vá: LAN TCP + Bluetooth PAN + chặn tự sát tự động khi MP = 0
- File: `game/game.jar`

## Cách dễ nhất: GitHub Actions

1. Tạo một repository GitHub mới.
2. Upload **toàn bộ nội dung** của thư mục/ZIP này, giữ nguyên `.github/workflows/build-apk.yml`.
3. Mở tab **Actions** → workflow **Build Ninja School APK** → **Run workflow**.
4. Khi job hoàn tất, tải artifact `NinjaSchoolOffline-v1.25.42-APK`.
5. Bên trong artifact có:
   - `NinjaSchoolOffline_v1.25.42_LAN_BluetoothPAN_MPfix.apk`
   - `SHA256SUMS.txt`

Workflow dùng Java 17, Android API 34, NDK `22.1.7171670`, Gradle wrapper của J2ME Loader và commit J2ME Loader `9b0fa48a0a0d1e61376c0b9af28b3d2caec0a4cc`. Bản FIX2 checkout commit bằng `actions/checkout`, tránh lỗi Git exit code 128 do fetch short SHA.

## Cách build trên PC có Android SDK

Yêu cầu: Git, Java 17, Android SDK API 34, NDK `22.1.7171670`.

```bash
git clone https://github.com/nikita36078/J2ME-Loader.git j2me-loader
cd j2me-loader
git checkout 9b0fa48
cd ..
./scripts/prepare_j2me_loader.sh ./j2me-loader ./game/game.jar
```

Tạo `j2me-loader/keystore.properties` và keystore, sau đó:

```bash
cd j2me-loader
./gradlew assembleMidletDebug
```

APK nằm trong `app/build/outputs/apk/`.

## Lưu ý kỹ thuật

- Đây là **port kit**, không phải APK đã build sẵn.
- JAR được đưa vào cấu hình `midletImplementation`, nên Android Gradle Plugin sẽ đưa bytecode game vào quá trình DEX cùng runtime J2ME Loader.
- J2ME Loader `midlet` flavor đọc manifest tại `app/src/midlet/resources/MIDLET-META-INF/MANIFEST.MF`; script tự sao chép manifest từ JAR vào đúng vị trí này.
- Chế độ Bluetooth của bản game hiện tại là **Bluetooth PAN + TCP**, không phải RFCOMM/JSR-82 trực tiếp.
- Vì môi trường ChatGPT hiện tại không có Android SDK/NDK và không cho tải các binary build tool cần thiết, APK cuối chưa được build/test end-to-end tại đây. Workflow này chuyển bước build sang GitHub-hosted runner, nơi Android toolchain được cài đầy đủ.
