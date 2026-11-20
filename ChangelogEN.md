#

<div align="center">

## Changelog

Version V3.8.1
			
	"Fixed the character freezing in place after the script was fully turned off: closing the hub now unanchors the character, removes leftover movers and re-enables every Humanoid state it had disabled.",
	"Fixed the character staying anchored after Stalk Active was switched off.",
	"Fixed the settings windows (ESP, Compatibility Report, Aim, Server List, Bunny Hop, RTX Shader Editor, RTX Presets, Models, Custom Crosshair, Custom Mouse and World) changing their transparency with Panel Transparency and leaving only text at the maximum value.",
	"Fixed the SH button in Classic style leaving only its text at the maximum Panel Transparency.",
	"Fixed the FPS drop with ESP enabled: Drawing objects are no longer rewritten with the same values, visibility checks run less often and the per-frame tables are reused.",
	"Fixed ESP slowly eating memory: target data and pool counters are reused every frame instead of being recreated.",
	"Adding snowfall and a snow cap to the SH button in the Winter theme, in both Classic and Dynamic Island styles."

version V3.8

	"Redesigned Appearance > Background: backgrounds are now a tile gallery with None, your saved backgrounds and an Add tile; pressing Add smoothly reveals the field for an Asset ID or link right below the tiles.",
	"Hover a background tile to see its Asset ID or URL, hover it and press the red cross to remove it. Pressing Use applies the background and saves it as a tile.",
	"Adding video backgrounds: paste a link or a workspace file ending in .mp4 or .webm, or video: followed by a video asset ID. The video loops without sound and follows Background Opacity, Background Zoom and Animated Drift Effect.",
	"Image links from outside Roblox are now downloaded and cached, so they work as a background too. GIF files are not supported.",
	"Panel Transparency now goes up to 100%, so panels, cards and their outlines can be made completely invisible.",
	"Adding the Winter menu theme: a deep night-blue palette with an icy accent, a twinkling garland along the top edge, snowdrifts in the bottom corners and softly falling snowflakes.",
	"The Winter theme is available in Appearance > Theme, in the UI Studio theme list and in saved configs, and its decorations are shown in the live preview and in UI Studio.",
	"The Winter decorations are drawn with interface elements instead of images, so they need no extra downloads and follow the window corner radius.",
	"Adding the GTA VI menu theme in honor of the game's release: a neon dusk palette with a pink-orange sunset glow, a setting sun, twinkling stars and a neon edge along the top.",
	"App Font buttons now have a thin outline, zoom in on hover and show the name of the font in a small tooltip.",
	"Theme cards now zoom in on hover and their colour strips become a little brighter.",
	"Near maximum Panel Transparency, the Asset ID / URL field, the source selector, the current track card, saved tracks, the playlist button and name field, Config name and Search configs now get an outline so they stay visible.",
	"The highlight of the sidebar sub-tabs now slides smoothly to the selected tab instead of fading in on each button.",
	"Renamed Emotes to Marketplace and added the Accessories section: browse Roblox accessories with search, sorting, price range and creator filters, plus Saved and Folders.",
	"Adding Try on for accessories: a preview window with your avatar slides in from the right, rotates on its own and can be turned by dragging.",
	"Adding the Wear button to accessory cards and to the Try on window: it puts the accessory on your character and turns into Take off, and worn accessories come back after respawn.",
	"Accessories now load with skeleton placeholders, a page switcher, a Retry button and search suggestions, just like the Emotes section.",
	"Fixed the Try on window staying on the screen when the menu was minimized or closed, and the Saved tab not updating when an accessory was removed from it."

version V3.7.1
			
	"Fixed the Developer Console and Remote Spy windows changing their transparency with Panel Transparency and their settings text being hard to read.",
	"Fixed the cursor flying to the top left corner and becoming unusable when Mouse Aim is enabled.",
	"Adding Panel Transparency support to Navigation Style: Floating Dock, Floating Pill, Segmented and Icon Rail.",
	"Adding Panel Transparency support to theme cards, Add Custom Theme, the All Themes button and the font buttons in Appearance.",
	"Adding Panel Transparency support to the sliding tab highlight at the top of Appearance.",
	"Adding Panel Transparency support to the Trim, Reset, Delete, Clear and Open buttons in QoL.",
	"Adding Panel Transparency support to the Copy, Go, Save Here, Back and Clear buttons in Teleport.",
	"Adding Panel Transparency support to server cards and their Join and Copy ID buttons in Server List."

version V3.7
			
	"Adding a version check via GitHub: the hub compares your version with the latest release and tells you when an update is available.",
	"Adding the update status to the Update Log and the welcome screen with a manual Check for Updates button.",
	"Fixed the Update Log not being translated into Russian.",
	"Adding the Halloween Nightmare shader: pitch-black blood-red fog, flickering light, lightning flashes and a pulsing vignette.",
	"Shaders now switch each other off, so only one shader is active at a time.",
	"Redesigned the welcome screen: minimalist style with smooth animations.",
	"Redesigned the loading screen: minimalist style with smooth animations.",
	"Adding the Dynamic Island style to HUD settings: a compact capsule in any screen corner that expands on hover or when features change.",
	"Adding Notification Position to Appearance > Notification System: choose any corner or the center of the screen.",
	"Adding the Mini Player to Music: a compact player in the bottom-right corner while the menu is minimized, with track info, play/pause, previous/next, seeking and a track list.",
	"Adding the Activity chart to Home > Account: a year of hub usage by day, by week or cumulative, hover a square to see the date, duration and time of use.",
	"Adding Navigation Style to Appearance > Window with live previews: Classic, Floating Dock, Floating Pill, Segmented and Icon Rail.",
	"Adding playlists to Music: create, rename and delete playlists, each one keeps its own tracks.",
	"Adding Crossfade to Music: the end of a track smoothly blends into the next one.",
	"Adding Spectrum by Ranges to Music: the bars react to PlaybackLoudness ranges in the title bar and in the Mini Player.",
	"Adding Hide Accessories and Hide Players to Boost FPS & World: hide accessories and other players for extra FPS.",
	"Macro Recorder now records mouse clicks and key presses together with movement and replays them.",
	"Adding a timeline to Macro Recorder: a point for every click and key, drag the handles to trim, drag a point to move it and delete the selected one.",
	"Adding playback speed to Macro Recorder: from 0.25x to 4x.",
	"Adding Smart Loop to Macro Recorder: loop delay, stop or wait on low HP, start position check with auto return and resume after respawn.",
	"Adding the RTX Shader Editor: build your own RTX shader with lighting, bloom, color, sun rays, depth of field and atmosphere settings, then save it as a preset.",
	"RTX Shader now has three presets: Standard, Vibrant and the new Golden Hour.",
	"Adding Item ESP: highlights dropped tools, pickups, proximity prompts and click detectors with names and distance.",
	"Fixed the server filters in Features > Server: Almost Empty, Almost Full and Occupancy Percent now scan several pages of servers instead of only the first 100, retry after rate limits and show the reason when loading fails.",
	"Redesigned Direct Connect: labeled fields, a Current button, input validation, focus and press animations. The Server ID field now uses the Place ID typed above it.",
	"Redesigned Home > Account: a card layout with Roblox registration date, first launch, hub version with update status, playtime progress toward the 10h achievement, executor and platform.",
	"Redesigned Home > Overview and added a Script Version plate with the update status and a Check for Updates button.",
	"Redesigned the FPS, Ping and Players graphs: smooth scrolling bars, automatic scaling, an average line, a live indicator and an intro animation.",
	"Fixed the interface turning fully orange when a config with the Halloween theme is auto-loaded: the saved theme is now kept after the hub finishes loading.",
	"Adding protection against duplicate launches: once the hub is running, it cannot be started again until the current UI is fully closed.",
	"Adding automatic menu size detection: the menu scales to your screen or monitor resolution and re-adapts when the window size changes.",
	"Redesigned the Teleport subsection: minimalist style with smooth animations.",
	"Adding a choice to enable or disable automatic menu resolution detection on the welcome screen.",
	"Adding the Command Palette: press Ctrl + K to quickly find any tab, feature, action or waypoint and run it from the keyboard.",
	"Adding Waypoints to Features > Teleport: save your position, return in one click, show world markers with distance, saved per place with keybinds.",
	"Adding smooth animated transitions between sections and subsections with direction-aware slide and fade.",
	"Adding skeleton placeholders instead of spinners and loading text in Scripts, Emotes, script previews and images.",
	"Redesigned Config: saved configs are now cards with a theme and background preview, place icon, save date and size, and hover animations.",
	"Adding pinned configs to Config: pin a config with the star and it stays at the top.",
	"Adding grouping of saved configs by place in Config, groups can be collapsed.",
	"Adding smooth cascading appearance of cards when opening any tab.",
	"Redesigned the Macro Recorder editor in a video editor style: separate tracks for movement, left click, right click and keys, clips with hold duration, a ruler, zoom with the mouse wheel, Shift + wheel to pan and Fit and zoom buttons.",
	"Adding a smooth playhead to the Macro Recorder: click the ruler to choose the start point, the current step is highlighted during playback and the view follows the playhead.",
	"Redesigned Settings > Binds: compact keycaps with a press animation, a recording animation while a key is being assigned, conflict highlighting and filters by category.",
	"Adding a spring animation to all toggle switches.",
	"Adding a live ESP preview: a small window in the ESP settings that shows changes to box color, thickness and style right away.",
	"Adding live previews for Name, Health, Tracer, Skeleton and Chams settings in ESP.",
	"Redesigned Features > Visuals: category cards ESP, Models, HUD and World with a counter of enabled functions, and mini icons on feature cards.",
	"Adding Position & Map to Features > Teleport: live X, Y and Z coordinates with a copy button, a field to go to typed coordinates and a mini-map with zoom.",
	"Adding Click-to-Teleport on the mini-map: click or tap a point and you land on the ground there; the map shows players, waypoints and recent teleports.",
	"Adding waypoint editing: rename a waypoint or move it to your current position.",
	"Adding Teleport History: every jump of the session with time and coordinates, a Go button for each entry, Back to the previous position and a keybind.",
	"Reworked notification sounds: Blip is now a soft drop, new Tick and Tap sounds, each sound has its own tone and softness.",
    "Redesigned Settings > Appearance: inner tabs Theme, Window, Background, Notifications, Language and Interface with slide transitions, a Theme grid with color strips and Add Custom Theme, and a Navigation Style carousel with animated mini-schemes.",
	"Redesigned the Server List in Features > Server: cards with players, ping and an occupancy bar, Join and Copy ID buttons, and servers load as you scroll.",
	"Redesigned Home > Developers and Home > Info in the style of Account and Overview: outlined cards, hover animations and copyable contacts.",
    "Redesigned Home > Update Log: releases are grouped into collapsible cards with NEW and FIX badges, older versions are collapsed."

Version V3.6
			
	"Adding the Dynamic Island style for the SH button, choose it in Appearance > Window Customization.",
	"Adding global search to Home, Features and Settings: type a name to find any feature or setting from any section.",
	"Adding UI Studio: a separate window with a full copy of the interface where you can customize the whole look, save it as a preset and apply it to the current UI.",
	"UI Studio covers themes and custom colors, fonts, corners, transparency, header, background image, gradient and effects.",
	"UI Studio now has a Gallery of ready-made presets and a Layout section for window size and navigation position.",
	"Adding Russian localization, English is still available in Appearance > Language.",
	"Adding the Bind Manager: bind any feature to a key with Toggle and Hold modes in Settings > Binds.",
	"Custom Keybinds from Features > QoL have moved into the Bind Manager.",
	"Adding code sharing: export your settings or UI Studio presets as a short code and import codes from others.",
	"Adding a customizable HUD with FPS, ping, players, clock and the list of active features.",
	"Adding automatic config loading for separate places, each place can have its own auto-load config.",
	"Adding 3 new animations for notifications: Pop, Drop and Fade.",
	"The Live Preview in Appearance has been replaced with UI Studio.",
	"Adding a search bar to Config for finding saved configs by name.",
	"Adding 3 notification sounds to Appearance > Notification System: Ping, Blip and Pop.",
	"Adding Collections to Scripts and Emotes: create folders and save scripts or emotes into them.",
	"Adding the robloxscripts.com service to Scripts."

version = V3.5
			
	"Adding flexible ESP settings [colors, gradients, and much more].",
	"Adding a color change feature to the Cyberpunk shader.",
	"Complete overhaul of the RTX shader.",
	"Fixed loading of the config with a low-quality image.",
	"Visual redesign of Script cards.",
	"Adding custom fonts via Asset ID.",
	"Adding the Info subsection to Home.",
	"Added a check for injector compatibility with script functions. [BETA!]",
	"Adding multiple visuals.",
	"Detailed information about the script is available in the Script section.",
	"Adding information about the developers.",
	"Adding a gradient background with style presets, custom colors, strength, angle and slow animation.",
	"Adding background effects: snowfall, twinkling stars, shooting stars and floating particles.",
	"Adding a Discord button to Home.",
	"Reworked the Halloween theme: new logo and icon, cobweb corner decorations.",
	"Adding a live UI preview window to Appearance that shows every appearance setting before you apply it.",
	"The theme editor now shows a preview of the theme before saving it.",
    "Adding saving configs for a specific place, the saved list shows the place where each config was saved."

version V3.4.1
			
	"Correcting the display of images in the script.",
	"A small visual update of the image upload.",
	"Fixed script card images not loading when a site served WebP or relative image links.",
	"Fixed the Scripts list getting stuck on loading after an error while building cards.",
	"Fixed failed image downloads never being retried until the next launch.",
	"Fixed the image cache folder growing without a limit.",
	"Fixed the hub GUI and its sounds being visible to the game inside PlayerGui and SoundService.",
	"Added support for the official Rscripts v1 API and its sorting options."

version V3.4
			
	"Visual change to certain objects.",
	"Changing the settings icons and the Features icon.",
	"Added two types of animations for the menu.",
	"Adding two subsections to Scripts and Emotes: Saved and Recent.",
	"Reworked Settings for the Scripts and Emotes sections [Now called Filters]",
	"Adding icons to some subsection buttons.",
	"Added the ability to resize the main menu.",
	"Addition of the new script search service HaxHell.",
	"Fixed the copying of loadstring references for scripts.",
	"Adding a Combat subsection to Features."

Version V3.3
			
	"Adding search bars to the Features, Emotes, and Scripts sections.",
	"Visual update of certain objects.",
	"Adding an \"Update Log\" subsection to Home.",
	"New Halloween menu theme.",
	"Fixed menu-related bugs.",
	"An option to select the sound played when pressing various switches and buttons has been added to the \"Appearance\" section.",
	"Fixed an issue where some objects did not change their transparency.",
	"Added Anti-AFK to the Misc subsection"

Version V3.2
			
	"Fixing Corner Radius bugs for Custom Background.",
	"Adding auto-loading for the selected config.",
	"Fixing bugs and sliders/switches not changing their position when loading the config.",
	"Added functionality to disable features when the menu is fully closed.",
	"Adding Music to Appearance.",
	"Increased the z-index for all menus and script objects so they are not overlapped by the game interface."

Version = V3.1", date = "Oct 6
			
	"Release Septus hub V3",
				
Version V3.2
			
	"Fixing menu bugs",
	"Pre-release",
				

## 💬 Telegram

<a href="https://telegram.me/RezinovieTapochkl">
    <img src="https://cdn.simpleicons.org/telegram" width="22" align="center"/>
</a>

**Есть идеи по улучшению?**  
Здесь вы можете предложить новые функции, сообщить об ошибках и оставить свои предложения по развитию проекта.

Have any ideas for improvement?
Here you can suggest new features, report bugs, and share your proposals for the project's development.
