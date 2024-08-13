clean:
	@echo "[+] Cleaning dependencies"
	flutter clean
	rm -rf pubspec.lock
	cd ios/ && rm -rf Podfile.lock
	cd ios/ && rm -rf Pods
	flutter pub get
	cd ios/ && pod repo update
	cd ios/ && pod install