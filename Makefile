SHELL := /bin/bash
.DEFAULT_GOAL := validate

.PHONY: validate lint security guard data unit snapshots coverage docs

# Recursive invocations deliberately preserve fail-fast ordering even under make -j.
validate:
	$(MAKE) lint
	$(MAKE) security
	$(MAKE) guard
	$(MAKE) data
	$(MAKE) unit
	$(MAKE) snapshots

lint:
	swiftlint lint --strict --config .swiftlint.yml

security:
	gitleaks detect --source . --redact --no-banner
	semgrep scan --config=p/ci --error --metrics=off .

guard:
	bash scripts/ci/check_firebase_detached.sh

data:
	python3 scripts/validate_venues_json.py
	python3 -m unittest discover -s scripts/tests -v

unit:
	swift test --disable-automatic-resolution

coverage:
	swift test --disable-automatic-resolution --enable-code-coverage
	mkdir -p .build/coverage
	cp "$$(swift test --show-code-coverage-path)" .build/coverage/noctocore-coverage.json
	python3 scripts/ci/report_coverage.py --minimum 70

snapshots:
	NOCTO_RECORD_SNAPSHOTS=0 xcodebuild -project NOCTO.xcodeproj -scheme NOCTO \
		-destination 'platform=iOS Simulator,name=iPhone 17,OS=26.6' \
		-only-testing:NOCTOUITests test

docs:
	mkdir -p .build/symbol-graphs .build/docc
	swift build --disable-automatic-resolution --target NOCTOCore \
		-Xswiftc -emit-symbol-graph -Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs
	xcrun docc convert Sources/NOCTOCore/NOCTOCore.docc \
		--additional-symbol-graph-dir .build/symbol-graphs \
		--fallback-display-name NOCTOCore \
		--fallback-bundle-identifier com.mario.NOCTO.NOCTOCore \
		--fallback-bundle-version 1 --output-path .build/docc/NOCTOCore.doccarchive
