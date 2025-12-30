import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "components"

FloatingWindow {
    id: root

    property var scheme: ({})
    property int monitorWidth: 2880
    property int monitorHeight: 1800
    property string homeDir: ""

    visible: false
    color: "transparent"

    // Current state
    property string currentSource: "wallhaven-anime"
    property string currentImageUrl: ""
    property string downloadedPath: ""
    property bool nsfwEnabled: false
    property bool isDownloading: false
    property bool isFetching: false

    // Reset source if current one doesn't support NSFW when enabled
    onNsfwEnabledChanged: {
        var allSources = animeSources.concat(generalSources);
        var current = allSources.find(s => s.id === currentSource);
        if (nsfwEnabled && current && !current.nsfw) {
            currentSource = "wallhaven-anime";
        }
    }

    // Wallpaper directory
    readonly property string wallpaperDir: homeDir + "/Pictures/Wallpapers"

    // Source definitions - separate arrays for QML Repeater compatibility
    // nsfw: true = supports NSFW, false = SFW only
    readonly property var animeSources: [
        { id: "wallhaven-anime", name: "Wallhaven Anime", nsfw: true },
        { id: "waifu", name: "Waifu.im", nsfw: true },
        { id: "nekobot", name: "Nekobot", nsfw: true },
        { id: "waifupics", name: "Waifu.pics", nsfw: true },
        { id: "danbooru", name: "Danbooru", nsfw: true },
        { id: "nekos", name: "Nekos.best", nsfw: false },
        { id: "nekos-life", name: "Nekos.life", nsfw: true }
    ]
    readonly property var generalSources: [
        { id: "wallhaven-general", name: "Wallhaven General", nsfw: true },
        { id: "picsum", name: "Picsum", nsfw: false },
        { id: "e621", name: "e621", nsfw: true },
        { id: "reddit-earthporn", name: "r/EarthPorn", nsfw: false },
        { id: "reddit-spaceporn", name: "r/SpacePorn", nsfw: false },
        { id: "reddit-imaginary", name: "r/ImaginaryLandscapes", nsfw: false }
    ]

    function show() {
        visible = true;
    }

    function hide() {
        visible = false;
        currentImageUrl = "";
        downloadedPath = "";
    }

    function fetchRandom() {
        isFetching = true;
        currentImageUrl = "";
        
        if (currentSource === "wallhaven-anime") {
            // Wallhaven anime only (category 010)
            var purity = nsfwEnabled ? "110" : "100";
            var url = "https://wallhaven.cc/api/v1/search?sorting=random&categories=010&purity=" + purity + "&atleast=" + monitorWidth + "x" + monitorHeight;
            apiRequest.command = ["curl", "-s", url];
            apiRequest.running = true;
        } else if (currentSource === "wallhaven-general") {
            // Wallhaven general only (category 100)
            var purity = nsfwEnabled ? "110" : "100";
            var url = "https://wallhaven.cc/api/v1/search?sorting=random&categories=100&purity=" + purity + "&atleast=" + monitorWidth + "x" + monitorHeight;
            apiRequest.command = ["curl", "-s", url];
            apiRequest.running = true;
        } else if (currentSource === "waifu") {
            // Waifu.im API
            var nsfw = nsfwEnabled ? "true" : "false";
            var url = "https://api.waifu.im/search?is_nsfw=" + nsfw;
            apiRequest.command = ["curl", "-s", url];
            apiRequest.running = true;
        } else if (currentSource === "picsum") {
            // Picsum - direct image URL
            currentImageUrl = "https://picsum.photos/" + monitorWidth + "/" + monitorHeight + "?random=" + Date.now();
            isFetching = false;
        } else if (currentSource === "nekobot") {
            // Nekobot API - anime/hentai images
            var type = nsfwEnabled ? "hentai" : "neko";
            var url = "https://nekobot.xyz/api/image?type=" + type;
            apiRequest.command = ["curl", "-s", url];
            apiRequest.running = true;
        } else if (currentSource === "waifupics") {
            // Waifu.pics API - anime images
            var category = nsfwEnabled ? "nsfw/waifu" : "sfw/waifu";
            var url = "https://api.waifu.pics/" + category;
            apiRequest.command = ["curl", "-s", url];
            apiRequest.running = true;
        } else if (currentSource === "e621") {
            // e621 API - artwork with NSFW support
            var rating = nsfwEnabled ? "e" : "s";
            var url = "https://e621.net/posts.json?limit=50&tags=order:random%20rating:" + rating + "%20type:jpg";
            apiRequest.command = ["curl", "-s", "-A", "WallpaperPicker/1.0", url];
            apiRequest.running = true;
        } else if (currentSource === "danbooru") {
            // Danbooru API - anime artwork (no random, use recent)
            var rating = nsfwEnabled ? "e,q" : "g,s";
            var url = "https://danbooru.donmai.us/posts.json?limit=50&tags=rating:" + rating + "+highres";
            apiRequest.command = ["curl", "-s", "-A", "WallpaperPicker/1.0", url];
            apiRequest.running = true;
        } else if (currentSource === "nekos") {
            // Nekos.best API - SFW anime images
            var url = "https://nekos.best/api/v2/neko";
            apiRequest.command = ["curl", "-s", url];
            apiRequest.running = true;
        } else if (currentSource === "nekos-life") {
            // Nekos.life API - anime images with NSFW
            var endpoint = nsfwEnabled ? "lewd" : "neko";
            var url = "https://nekos.life/api/v2/img/" + endpoint;
            apiRequest.command = ["curl", "-s", url];
            apiRequest.running = true;
        } else if (currentSource === "reddit-earthporn") {
            // Reddit r/EarthPorn - landscape photography
            var url = "https://www.reddit.com/r/EarthPorn/hot.json?limit=50";
            apiRequest.command = ["curl", "-s", "-A", "WallpaperPicker/1.0", url];
            apiRequest.running = true;
        } else if (currentSource === "reddit-spaceporn") {
            // Reddit r/SpacePorn - space photography
            var url = "https://www.reddit.com/r/SpacePorn/hot.json?limit=50";
            apiRequest.command = ["curl", "-s", "-A", "WallpaperPicker/1.0", url];
            apiRequest.running = true;
        } else if (currentSource === "reddit-imaginary") {
            // Reddit r/ImaginaryLandscapes - fantasy landscape art
            var url = "https://www.reddit.com/r/ImaginaryLandscapes/hot.json?limit=50";
            apiRequest.command = ["curl", "-s", "-A", "WallpaperPicker/1.0", url];
            apiRequest.running = true;
        }
    }

    function generateFilename() {
        var now = new Date();
        var timestamp = now.toISOString().replace(/[:.]/g, "-").slice(0, 19);
        var ext = currentImageUrl.toLowerCase().endsWith(".png") ? ".png" : ".jpg";
        return "wallpaper_" + timestamp + "_" + currentSource + ext;
    }

    function acceptWallpaper() {
        if (currentImageUrl === "" || isDownloading) return;

        isDownloading = true;
        var filename = generateFilename();
        downloadedPath = wallpaperDir + "/" + filename;

        // Ensure directory exists and download
        mkdirProcess.command = ["mkdir", "-p", wallpaperDir];
        mkdirProcess.running = true;
    }

    // API request for Wallhaven and Waifu.im
    Process {
        id: apiRequest
        
        stdout: SplitParser {
            onRead: data => {
                apiResponse = data;
            }
        }

        onExited: function(code, status) {
            isFetching = false;
            if (code === 0 && apiResponse) {
                try {
                    var response = JSON.parse(apiResponse);
                    
                    if (currentSource.startsWith("wallhaven")) {
                        // Wallhaven response
                        if (response.data && response.data.length > 0) {
                            var randomIndex = Math.floor(Math.random() * response.data.length);
                            currentImageUrl = response.data[randomIndex].path;
                        } else {
                            console.error("Wallhaven: No images found");
                        }
                    } else if (currentSource === "waifu") {
                        // Waifu.im response
                        if (response.images && response.images.length > 0) {
                            currentImageUrl = response.images[0].url;
                        } else {
                            console.error("Waifu.im: No images found");
                        }
                    } else if (currentSource === "nekobot") {
                        // Nekobot response
                        if (response.success && response.message) {
                            currentImageUrl = response.message;
                        } else {
                            console.error("Nekobot: No image found");
                        }
                    } else if (currentSource === "waifupics") {
                        // Waifu.pics response
                        if (response.url) {
                            currentImageUrl = response.url;
                        } else {
                            console.error("Waifu.pics: No image found");
                        }
                    } else if (currentSource === "e621") {
                        // e621 response
                        if (response.posts && response.posts.length > 0) {
                            var randomIndex = Math.floor(Math.random() * response.posts.length);
                            var post = response.posts[randomIndex];
                            if (post.file && post.file.url) {
                                currentImageUrl = post.file.url;
                            } else {
                                console.error("e621: No image URL found");
                            }
                        } else {
                            console.error("e621: No posts found");
                        }
                    } else if (currentSource === "danbooru") {
                        // Danbooru response
                        if (response && response.length > 0) {
                            var validPosts = response.filter(p => p.file_url && !p.is_banned);
                            if (validPosts.length > 0) {
                                var randomIndex = Math.floor(Math.random() * validPosts.length);
                                currentImageUrl = validPosts[randomIndex].file_url;
                            } else {
                                console.error("Danbooru: No valid images found");
                            }
                        } else {
                            console.error("Danbooru: No posts found");
                        }
                    } else if (currentSource === "nekos") {
                        // Nekos.best response
                        if (response.results && response.results.length > 0) {
                            currentImageUrl = response.results[0].url;
                        } else {
                            console.error("Nekos.best: No images found");
                        }
                    } else if (currentSource === "nekos-life") {
                        // Nekos.life response
                        if (response.url) {
                            currentImageUrl = response.url;
                        } else {
                            console.error("Nekos.life: No image found");
                        }
                    } else if (currentSource.startsWith("reddit-")) {
                        // Reddit response
                        if (response.data && response.data.children && response.data.children.length > 0) {
                            var validPosts = response.data.children.filter(c => {
                                var url = c.data.url || "";
                                return (url.endsWith(".jpg") || url.endsWith(".png") || url.includes("i.redd.it") || url.includes("i.imgur.com")) && !c.data.over_18;
                            });
                            if (validPosts.length > 0) {
                                var randomIndex = Math.floor(Math.random() * validPosts.length);
                                var url = validPosts[randomIndex].data.url;
                                // Handle imgur links without extension
                                if (url.includes("imgur.com") && !url.endsWith(".jpg") && !url.endsWith(".png")) {
                                    url = url + ".jpg";
                                }
                                currentImageUrl = url;
                            } else {
                                console.error("Reddit: No valid images found");
                            }
                        } else {
                            console.error("Reddit: No posts found");
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse API response:", e);
                }
                apiResponse = "";
            } else {
                console.error("API request failed:", code);
            }
        }
    }
    
    property string apiResponse: ""

    // Create wallpaper directory
    Process {
        id: mkdirProcess

        onExited: function(code, status) {
            if (code === 0) {
                downloadProcess.command = ["curl", "-L", "-o", downloadedPath, currentImageUrl];
                downloadProcess.running = true;
            } else {
                isDownloading = false;
                console.error("Failed to create directory");
            }
        }
    }

    // Download image
    Process {
        id: downloadProcess

        onExited: function(code, status) {
            if (code === 0) {
                setWallpaperProcess.command = ["caelestia", "wallpaper", "-f", downloadedPath];
                setWallpaperProcess.running = true;
            } else {
                isDownloading = false;
                console.error("Failed to download image");
            }
        }
    }

    // Set wallpaper with caelestia
    Process {
        id: setWallpaperProcess

        onExited: function(code, status) {
            isDownloading = false;
            if (code === 0) {
                root.hide();
            } else {
                console.error("Failed to set wallpaper:", code);
            }
        }
    }

    Rectangle {
        width: 1200
        height: 700
        anchors.centerIn: parent
        color: scheme.surfaceContainer || "#201f23"
        radius: 16
        border.width: 1
        border.color: scheme.outline || "#918f9a"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "Wallpaper Picker"
                    color: scheme.onSurface || "#e5e1e7"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                // NSFW Toggle
                Rectangle {
                    width: nsfwToggle.width + 16
                    height: 28
                    radius: 6
                    color: nsfwEnabled ? (scheme.errorContainer || "#93000a") : (scheme.surfaceContainerHigh || "#2a292e")
                    border.width: 1
                    border.color: nsfwEnabled ? (scheme.error || "#ffb4ab") : (scheme.outline || "#918f9a")

                    Text {
                        id: nsfwToggle
                        anchors.centerIn: parent
                        text: "NSFW"
                        color: nsfwEnabled ? (scheme.onErrorContainer || "#ffdad6") : (scheme.onSurfaceVariant || "#c8c5d1")
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: nsfwEnabled = !nsfwEnabled
                    }
                }

                // Close button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: closeArea.containsMouse ? (scheme.surfaceContainerHighest || "#353438") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "X"
                        color: scheme.onSurfaceVariant || "#c8c5d1"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.hide()
                    }
                }
            }

            // Source selector - two rows
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                // Anime sources
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Anime:"
                        color: scheme.onSurfaceVariant || "#c8c5d1"
                        font.pixelSize: 12
                        Layout.preferredWidth: 50
                    }

                    Repeater {
                        model: animeSources

                        Rectangle {
                            required property var modelData

                            visible: !nsfwEnabled || modelData.nsfw
                            width: visible ? sourceText.width + 16 : 0
                            height: visible ? 26 : 0
                            radius: 6
                            color: currentSource === modelData.id
                                ? (scheme.primaryContainer || "#7171ac")
                                : (sourceMouseArea.containsMouse ? (scheme.surfaceContainerHigh || "#2a292e") : "transparent")
                            border.width: currentSource === modelData.id ? 0 : 1
                            border.color: scheme.outline || "#918f9a"

                            Text {
                                id: sourceText
                                anchors.centerIn: parent
                                text: modelData.name
                                color: currentSource === modelData.id
                                    ? (scheme.onPrimaryContainer || "#ffffff")
                                    : (scheme.onSurface || "#e5e1e7")
                                font.pixelSize: 11
                                font.weight: currentSource === modelData.id ? Font.Medium : Font.Normal
                            }

                            MouseArea {
                                id: sourceMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: currentSource = modelData.id
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                // General sources
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "General:"
                        color: scheme.onSurfaceVariant || "#c8c5d1"
                        font.pixelSize: 12
                        Layout.preferredWidth: 50
                    }

                    Repeater {
                        model: generalSources

                        Rectangle {
                            required property var modelData

                            visible: !nsfwEnabled || modelData.nsfw
                            width: visible ? sourceText2.width + 16 : 0
                            height: visible ? 26 : 0
                            radius: 6
                            color: currentSource === modelData.id
                                ? (scheme.primaryContainer || "#7171ac")
                                : (sourceMouseArea2.containsMouse ? (scheme.surfaceContainerHigh || "#2a292e") : "transparent")
                            border.width: currentSource === modelData.id ? 0 : 1
                            border.color: scheme.outline || "#918f9a"

                            Text {
                                id: sourceText2
                                anchors.centerIn: parent
                                text: modelData.name
                                color: currentSource === modelData.id
                                    ? (scheme.onPrimaryContainer || "#ffffff")
                                    : (scheme.onSurface || "#e5e1e7")
                                font.pixelSize: 11
                                font.weight: currentSource === modelData.id ? Font.Medium : Font.Normal
                            }

                            MouseArea {
                                id: sourceMouseArea2
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: currentSource = modelData.id
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }

            // Image preview
            ImagePreview {
                id: imagePreview
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: currentImageUrl
                scheme: root.scheme
                fetching: isFetching
            }

            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    text: isFetching ? "Fetching..." : "Random"
                    scheme: root.scheme
                    enabled: !imagePreview.loading && !isDownloading && !isFetching
                    onClicked: fetchRandom()
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: isDownloading ? "Setting..." : "Accept"
                    scheme: root.scheme
                    primary: true
                    enabled: currentImageUrl !== "" && !imagePreview.loading && !isDownloading && !isFetching
                    onClicked: acceptWallpaper()
                }

                Button {
                    text: "Close"
                    scheme: root.scheme
                    onClicked: root.hide()
                }
            }
        }
    }
}
