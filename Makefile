APP      = Teleprompter
BUILD    = build
BUNDLE   = $(BUILD)/$(APP).app
MACOS    = $(BUNDLE)/Contents/MacOS
RSRC     = $(BUNDLE)/Contents/Resources
SOURCES  = $(wildcard Sources/*.swift)

.PHONY: all run clean

all: $(MACOS)/$(APP)

$(MACOS)/$(APP): $(SOURCES)
	@mkdir -p $(MACOS) $(RSRC)
	swiftc $(SOURCES) \
		-o $(MACOS)/$(APP) \
		-framework AppKit \
		-framework Foundation \
		-target arm64-apple-macos12.0 \
		-O
	@cp Resources/Info.plist $(BUNDLE)/Contents/Info.plist
	@cp Resources/AppIcon.icns $(RSRC)/AppIcon.icns
	@echo "✅ Built $(BUNDLE)"

run: all
	@open $(BUNDLE)

clean:
	@rm -rf $(BUILD)
	@echo "🗑  Cleaned"
