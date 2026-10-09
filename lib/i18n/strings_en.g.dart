///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$en common = Translations$common$en.internal(_root);
	late final Translations$home$en home = Translations$home$en.internal(_root);
	late final Translations$sentry$en sentry = Translations$sentry$en.internal(_root);
	late final Translations$settings$en settings = Translations$settings$en.internal(_root);
	late final Translations$logs$en logs = Translations$logs$en.internal(_root);
	late final Translations$login$en login = Translations$login$en.internal(_root);
	late final Translations$profile$en profile = Translations$profile$en.internal(_root);
	late final Translations$appInfo$en appInfo = Translations$appInfo$en.internal(_root);
	late final Translations$update$en update = Translations$update$en.internal(_root);
	late final Translations$editor$en editor = Translations$editor$en.internal(_root);
	late final Translations$searchResults$en searchResults = Translations$searchResults$en.internal(_root);
	late final Translations$onboarding$en onboarding = Translations$onboarding$en.internal(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Continue'
	String get continueBtn => 'Continue';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: home
class Translations$home$en {
	Translations$home$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$home$tabs$en tabs = Translations$home$tabs$en.internal(_root);
	late final Translations$home$titles$en titles = Translations$home$titles$en.internal(_root);
	late final Translations$home$tooltips$en tooltips = Translations$home$tooltips$en.internal(_root);
	late final Translations$home$create$en create = Translations$home$create$en.internal(_root);

	/// en: 'Welcome to Saber'
	String get welcome => 'Welcome to Saber';

	/// en: 'The file you selected is not supported. Please select an sbn, sbn2, sba, or pdf file.'
	String get invalidFormat => 'The file you selected is not supported. Please select an sbn, sbn2, sba, or pdf file.';

	/// en: 'No files found'
	String get noFiles => 'No files found';

	/// en: 'No preview available'
	String get noPreviewAvailable => 'No preview available';

	/// en: 'Tap the + button to create a new note'
	String get createNewNote => 'Tap the + button to create a new note';

	/// en: 'Go back to the previous folder'
	String get backFolder => 'Go back to the previous folder';

	late final Translations$home$newFolder$en newFolder = Translations$home$newFolder$en.internal(_root);
	late final Translations$home$renameNote$en renameNote = Translations$home$renameNote$en.internal(_root);
	late final Translations$home$moveNote$en moveNote = Translations$home$moveNote$en.internal(_root);
	late final Translations$home$search$en search = Translations$home$search$en.internal(_root);

	/// en: 'Delete note'
	String get deleteNote => 'Delete note';

	late final Translations$home$deleteNoteDialog$en deleteNoteDialog = Translations$home$deleteNoteDialog$en.internal(_root);
	late final Translations$home$renameFolder$en renameFolder = Translations$home$renameFolder$en.internal(_root);
	late final Translations$home$deleteFolder$en deleteFolder = Translations$home$deleteFolder$en.internal(_root);
}

// Path: sentry
class Translations$sentry$en {
	Translations$sentry$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$sentry$consent$en consent = Translations$sentry$consent$en.internal(_root);
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$prefCategories$en prefCategories = Translations$settings$prefCategories$en.internal(_root);
	late final Translations$settings$prefLabels$en prefLabels = Translations$settings$prefLabels$en.internal(_root);
	late final Translations$settings$prefDescriptions$en prefDescriptions = Translations$settings$prefDescriptions$en.internal(_root);
	late final Translations$settings$themeModes$en themeModes = Translations$settings$themeModes$en.internal(_root);
	late final Translations$settings$layoutSizes$en layoutSizes = Translations$settings$layoutSizes$en.internal(_root);
	late final Translations$settings$accentColorPicker$en accentColorPicker = Translations$settings$accentColorPicker$en.internal(_root);

	/// en: 'Auto'
	String get systemLanguage => 'Auto';

	List<String> get axisDirections => [
		'Top',
		'Right',
		'Bottom',
		'Left',
	];
	late final Translations$settings$reset$en reset = Translations$settings$reset$en.internal(_root);

	/// en: 'Resync everything'
	String get resyncEverything => 'Resync everything';

	/// en: 'Open Saber folder'
	String get openDataDir => 'Open Saber folder';

	late final Translations$settings$customDataDir$en customDataDir = Translations$settings$customDataDir$en.internal(_root);

	/// en: 'Never'
	String get autosaveDisabled => 'Never';

	/// en: 'Never'
	String get shapeRecognitionDisabled => 'Never';
}

// Path: logs
class Translations$logs$en {
	Translations$logs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Logs'
	String get logs => 'Logs';

	/// en: 'View logs'
	String get viewLogs => 'View logs';

	/// en: 'Logs contain information useful for debugging and development'
	String get debuggingInfo => 'Logs contain information useful for debugging and development';

	/// en: 'No logs here!'
	String get noLogs => 'No logs here!';

	/// en: 'Logs will appear here as you use the app'
	String get useTheApp => 'Logs will appear here as you use the app';
}

// Path: login
class Translations$login$en {
	Translations$login$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get title => 'Login';

	late final Translations$login$form$en form = Translations$login$form$en.internal(_root);

	/// en: 'Don't have an account yet? ${linkToSignup(Sign up now)}!'
	TextSpan signup({required InlineSpanBuilder linkToSignup}) => TextSpan(children: [
		const TextSpan(text: 'Don\'t have an account yet? '),
		linkToSignup('Sign up now'),
		const TextSpan(text: '!'),
	]);

	/// en: 'Not you? ${undoLogin(Choose another account)}.'
	TextSpan notYou({required InlineSpanBuilder undoLogin}) => TextSpan(children: [
		const TextSpan(text: 'Not you? '),
		undoLogin('Choose another account'),
		const TextSpan(text: '.'),
	]);

	late final Translations$login$status$en status = Translations$login$status$en.internal(_root);
	late final Translations$login$ncLoginStep$en ncLoginStep = Translations$login$ncLoginStep$en.internal(_root);
	late final Translations$login$encLoginStep$en encLoginStep = Translations$login$encLoginStep$en.internal(_root);
}

// Path: profile
class Translations$profile$en {
	Translations$profile$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My profile'
	String get title => 'My profile';

	/// en: 'Log out'
	String get logout => 'Log out';

	/// en: 'You're using $used of $total ($percent%)'
	String quotaUsage({required Object used, required Object total, required Object percent}) => 'You\'re using ${used} of ${total} (${percent}%)';

	/// en: 'Connected to'
	String get connectedTo => 'Connected to';

	late final Translations$profile$quickLinks$en quickLinks = Translations$profile$quickLinks$en.internal(_root);

	/// en: 'Frequently asked questions'
	String get faqTitle => 'Frequently asked questions';

	List<dynamic> get faq => [
		Translations$profile$faq$0$en.internal(_root),
		Translations$profile$faq$1$en.internal(_root),
		Translations$profile$faq$2$en.internal(_root),
		Translations$profile$faq$3$en.internal(_root),
	];
}

// Path: appInfo
class Translations$appInfo$en {
	Translations$appInfo$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Saber Copyright © 2022-$buildYear Adil Hanney This program comes with absolutely no warranty. This is free software, and you are welcome to redistribute it under certain conditions.'
	String licenseNotice({required Object buildYear}) => 'Saber  Copyright © 2022-${buildYear}  Adil Hanney\nThis program comes with absolutely no warranty. This is free software, and you are welcome to redistribute it under certain conditions.';

	/// en: 'DEBUG'
	String get debug => 'DEBUG';

	/// en: 'Tap here to sponsor me or buy more storage'
	String get sponsorButton => 'Tap here to sponsor me or buy more storage';

	/// en: 'Tap here to view more license information'
	String get licenseButton => 'Tap here to view more license information';

	/// en: 'Tap here to view the privacy policy'
	String get privacyPolicyButton => 'Tap here to view the privacy policy';
}

// Path: update
class Translations$update$en {
	Translations$update$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Update available'
	String get updateAvailable => 'Update available';

	/// en: 'A new version of the app is available:'
	String get updateAvailableDescription => 'A new version of the app is available:';

	/// en: 'Update'
	String get update => 'Update';

	/// en: 'The download isn't available yet for your platform. Please check back shortly.'
	String get downloadNotAvailableYet => 'The download isn\'t available yet for your platform. Please check back shortly.';
}

// Path: editor
class Translations$editor$en {
	Translations$editor$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$editor$toolbar$en toolbar = Translations$editor$toolbar$en.internal(_root);
	late final Translations$editor$pens$en pens = Translations$editor$pens$en.internal(_root);
	late final Translations$editor$penOptions$en penOptions = Translations$editor$penOptions$en.internal(_root);
	late final Translations$editor$colors$en colors = Translations$editor$colors$en.internal(_root);
	late final Translations$editor$imageOptions$en imageOptions = Translations$editor$imageOptions$en.internal(_root);
	late final Translations$editor$selectionBar$en selectionBar = Translations$editor$selectionBar$en.internal(_root);
	late final Translations$editor$menu$en menu = Translations$editor$menu$en.internal(_root);
	late final Translations$editor$readOnlyBanner$en readOnlyBanner = Translations$editor$readOnlyBanner$en.internal(_root);
	late final Translations$editor$versionTooNew$en versionTooNew = Translations$editor$versionTooNew$en.internal(_root);
	late final Translations$editor$quill$en quill = Translations$editor$quill$en.internal(_root);
	late final Translations$editor$hud$en hud = Translations$editor$hud$en.internal(_root);

	/// en: 'Pages'
	String get pages => 'Pages';

	/// en: 'Untitled'
	String get untitled => 'Untitled';

	/// en: 'Saving your changes... You can safely exit the editor when it's done'
	String get needsToSaveBeforeExiting => 'Saving your changes... You can safely exit the editor when it\'s done';

	late final Translations$editor$canvasHud$en canvasHud = Translations$editor$canvasHud$en.internal(_root);
	late final Translations$editor$layers$en layers = Translations$editor$layers$en.internal(_root);
	late final Translations$editor$pageGrid$en pageGrid = Translations$editor$pageGrid$en.internal(_root);
	late final Translations$editor$presentation$en presentation = Translations$editor$presentation$en.internal(_root);
	late final Translations$editor$elements$en elements = Translations$editor$elements$en.internal(_root);
	late final Translations$editor$tools$en tools = Translations$editor$tools$en.internal(_root);
	late final Translations$editor$stickyNote$en stickyNote = Translations$editor$stickyNote$en.internal(_root);
	late final Translations$editor$actions$en actions = Translations$editor$actions$en.internal(_root);
	late final Translations$editor$stickers$en stickers = Translations$editor$stickers$en.internal(_root);
	late final Translations$editor$bookmark$en bookmark = Translations$editor$bookmark$en.internal(_root);
	late final Translations$editor$tape$en tape = Translations$editor$tape$en.internal(_root);
	late final Translations$editor$lasso$en lasso = Translations$editor$lasso$en.internal(_root);
	late final Translations$editor$drafting$en drafting = Translations$editor$drafting$en.internal(_root);
	late final Translations$editor$outline$en outline = Translations$editor$outline$en.internal(_root);
	late final Translations$editor$sheet$en sheet = Translations$editor$sheet$en.internal(_root);
	late final Translations$editor$eraser$en eraser = Translations$editor$eraser$en.internal(_root);
	late final Translations$editor$header$en header = Translations$editor$header$en.internal(_root);
	late final Translations$editor$palette$en palette = Translations$editor$palette$en.internal(_root);
}

// Path: searchResults
class Translations$searchResults$en {
	Translations$searchResults$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Page $page: "$snippet"'
	String textMatch({required Object page, required Object snippet}) => 'Page ${page}: "${snippet}"';

	/// en: 'Page $page – colour $hex'
	String colorMatch({required Object page, required Object hex}) => 'Page ${page} – colour ${hex}';

	/// en: 'Page $page – tool: $tool'
	String toolMatch({required Object page, required Object tool}) => 'Page ${page} – tool: ${tool}';
}

// Path: onboarding
class Translations$onboarding$en {
	Translations$onboarding$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$onboarding$paper$en paper = Translations$onboarding$paper$en.internal(_root);
	late final Translations$onboarding$gestures$en gestures = Translations$onboarding$gestures$en.internal(_root);
	late final Translations$onboarding$tape$en tape = Translations$onboarding$tape$en.internal(_root);
	late final Translations$onboarding$elements$en elements = Translations$onboarding$elements$en.internal(_root);

	/// en: 'Welcome Guide'
	String get title => 'Welcome Guide';

	/// en: 'Try Playground'
	String get tryPlayground => 'Try Playground';

	/// en: 'Get Started'
	String get getStarted => 'Get Started';
}

// Path: home.tabs
class Translations$home$tabs$en {
	Translations$home$tabs$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Browse'
	String get browse => 'Browse';

	/// en: 'Whiteboard'
	String get whiteboard => 'Whiteboard';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: home.titles
class Translations$home$titles$en {
	Translations$home$titles$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recent notes'
	String get home => 'Recent notes';

	/// en: 'Browse'
	String get browse => 'Browse';

	/// en: 'Whiteboard'
	String get whiteboard => 'Whiteboard';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: home.tooltips
class Translations$home$tooltips$en {
	Translations$home$tooltips$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New note'
	String get newNote => 'New note';

	/// en: 'Show update dialog'
	String get showUpdateDialog => 'Show update dialog';

	/// en: 'Export note'
	String get exportNote => 'Export note';
}

// Path: home.create
class Translations$home$create$en {
	Translations$home$create$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New note'
	String get newNote => 'New note';

	/// en: 'Import note'
	String get importNote => 'Import note';
}

// Path: home.newFolder
class Translations$home$newFolder$en {
	Translations$home$newFolder$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New folder'
	String get newFolder => 'New folder';

	/// en: 'Folder name'
	String get folderName => 'Folder name';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Folder name can't be empty'
	String get folderNameEmpty => 'Folder name can\'t be empty';

	/// en: 'Folder name can't contain a slash'
	String get folderNameContainsSlash => 'Folder name can\'t contain a slash';

	/// en: 'Folder already exists'
	String get folderNameExists => 'Folder already exists';
}

// Path: home.renameNote
class Translations$home$renameNote$en {
	Translations$home$renameNote$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Rename note'
	String get renameNote => 'Rename note';

	/// en: 'Note name'
	String get noteName => 'Note name';

	/// en: 'Rename'
	String get rename => 'Rename';

	/// en: 'Note name can't be empty'
	String get noteNameEmpty => 'Note name can\'t be empty';

	/// en: 'A note with this name already exists'
	String get noteNameExists => 'A note with this name already exists';

	/// en: 'Note name contains forbidden characters'
	String get noteNameForbiddenCharacters => 'Note name contains forbidden characters';

	/// en: 'Note name reserved'
	String get noteNameReserved => 'Note name reserved';
}

// Path: home.moveNote
class Translations$home$moveNote$en {
	Translations$home$moveNote$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Move note'
	String get moveNote => 'Move note';

	/// en: 'Move $n notes'
	String moveNotes({required Object n}) => 'Move ${n} notes';

	/// en: 'Move $f'
	String moveName({required Object f}) => 'Move ${f}';

	/// en: 'Move'
	String get move => 'Move';

	/// en: 'Note will be renamed to $newName'
	String renamedTo({required Object newName}) => 'Note will be renamed to ${newName}';

	/// en: 'The following notes will be renamed:'
	String get multipleRenamedTo => 'The following notes will be renamed:';

	/// en: '$n notes will be renamed to avoid conflicts'
	String numberRenamedTo({required Object n}) => '${n} notes will be renamed to avoid conflicts';
}

// Path: home.search
class Translations$home$search$en {
	Translations$home$search$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search notes'
	String get hint => 'Search notes';

	/// en: 'Scanning...'
	String get scanning => 'Scanning...';

	/// en: '$n results found'
	String resultsFound({required Object n}) => '${n} results found';

	/// en: 'No results found'
	String get noResults => 'No results found';
}

// Path: home.deleteNoteDialog
class Translations$home$deleteNoteDialog$en {
	Translations$home$deleteNoteDialog$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete $n notes'
	String deleteNotes({required Object n}) => 'Delete ${n} notes';

	/// en: 'Delete $f'
	String deleteName({required Object f}) => 'Delete ${f}';

	/// en: '(one) {Permanently delete the selected note?} (other) {Permanently delete the selected notes?}'
	String confirmDelete({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Permanently delete the selected note?',
		other: 'Permanently delete the selected notes?',
	);

	/// en: 'Delete'
	String get delete => 'Delete';
}

// Path: home.renameFolder
class Translations$home$renameFolder$en {
	Translations$home$renameFolder$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Rename folder'
	String get renameFolder => 'Rename folder';

	/// en: 'Folder name'
	String get folderName => 'Folder name';

	/// en: 'Rename'
	String get rename => 'Rename';

	/// en: 'Folder name can't be empty'
	String get folderNameEmpty => 'Folder name can\'t be empty';

	/// en: 'Folder name can't contain a slash'
	String get folderNameContainsSlash => 'Folder name can\'t contain a slash';

	/// en: 'A folder with this name already exists'
	String get folderNameExists => 'A folder with this name already exists';
}

// Path: home.deleteFolder
class Translations$home$deleteFolder$en {
	Translations$home$deleteFolder$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete folder'
	String get deleteFolder => 'Delete folder';

	/// en: 'Delete $f'
	String deleteName({required Object f}) => 'Delete ${f}';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Also delete all notes inside this folder'
	String get alsoDeleteContents => 'Also delete all notes inside this folder';
}

// Path: sentry.consent
class Translations$sentry$consent$en {
	Translations$sentry$consent$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Help improve Saber?'
	String get title => 'Help improve Saber?';

	late final Translations$sentry$consent$description$en description = Translations$sentry$consent$description$en.internal(_root);
	late final Translations$sentry$consent$answers$en answers = Translations$sentry$consent$answers$en.internal(_root);
}

// Path: settings.prefCategories
class Translations$settings$prefCategories$en {
	Translations$settings$prefCategories$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'General'
	String get general => 'General';

	/// en: 'Writing'
	String get writing => 'Writing';

	/// en: 'Editor'
	String get editor => 'Editor';

	/// en: 'Performance'
	String get performance => 'Performance';

	/// en: 'Advanced'
	String get advanced => 'Advanced';
}

// Path: settings.prefLabels
class Translations$settings$prefLabels$en {
	Translations$settings$prefLabels$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Language'
	String get locale => 'Language';

	/// en: 'App theme'
	String get appTheme => 'App theme';

	/// en: 'Theme type'
	String get platform => 'Theme type';

	/// en: 'Layout type'
	String get layoutSize => 'Layout type';

	/// en: 'Custom accent color'
	String get customAccentColor => 'Custom accent color';

	/// en: 'Atkinson Hyperlegible font'
	String get hyperlegibleFont => 'Atkinson Hyperlegible font';

	/// en: 'Check for Saber updates'
	String get shouldCheckForUpdates => 'Check for Saber updates';

	/// en: 'Faster updates'
	String get shouldAlwaysAlertForUpdates => 'Faster updates';

	/// en: 'Allow insecure connections'
	String get allowInsecureConnections => 'Allow insecure connections';

	/// en: 'Toolbar position'
	String get editorToolbarAlignment => 'Toolbar position';

	/// en: 'Show the toolbar in fullscreen mode'
	String get editorToolbarShowInFullscreen => 'Show the toolbar in fullscreen mode';

	/// en: 'Invert notes in dark mode'
	String get editorAutoInvert => 'Invert notes in dark mode';

	/// en: 'Prefer greyscale colors'
	String get preferGreyscale => 'Prefer greyscale colors';

	/// en: 'Maximum image size'
	String get maxImageSize => 'Maximum image size';

	/// en: 'Auto-clear the whiteboard'
	String get autoClearWhiteboardOnExit => 'Auto-clear the whiteboard';

	/// en: 'Auto-disable the eraser'
	String get disableEraserAfterUse => 'Auto-disable the eraser';

	/// en: 'Hide the finger drawing toggle'
	String get hideFingerDrawingToggle => 'Hide the finger drawing toggle';

	/// en: 'Auto-disable finger drawing'
	String get autoDisableFingerDrawingWhenStylusDetected => 'Auto-disable finger drawing';

	/// en: 'Prompt you to rename new notes'
	String get editorPromptRename => 'Prompt you to rename new notes';

	/// en: 'Don't save preset colors in recent colors'
	String get recentColorsDontSavePresets => 'Don\'t save preset colors in recent colors';

	/// en: 'How many recent colors to store'
	String get recentColorsLength => 'How many recent colors to store';

	/// en: 'Print page indicators'
	String get printPageIndicators => 'Print page indicators';

	/// en: 'Auto-save'
	String get autosave => 'Auto-save';

	/// en: 'Shape recognition delay'
	String get shapeRecognitionDelay => 'Shape recognition delay';

	/// en: 'Auto straighten lines'
	String get autoStraightenLines => 'Auto straighten lines';

	/// en: 'Simplified home layout'
	String get simplifiedHomeLayout => 'Simplified home layout';

	/// en: 'Custom Saber folder'
	String get customDataDir => 'Custom Saber folder';

	/// en: 'Error reporting'
	String get sentry => 'Error reporting';

	/// en: 'Pen Pressure Curve'
	String get penPressureCurve => 'Pen Pressure Curve';

	/// en: 'Scribble to erase'
	String get scribbleToErase => 'Scribble to erase';

	/// en: 'Default to Infinite Canvas (2D)'
	String get defaultInfiniteCanvas => 'Default to Infinite Canvas (2D)';

	/// en: 'Welcome Guide & Onboarding'
	String get welcomeGuide => 'Welcome Guide & Onboarding';
}

// Path: settings.prefDescriptions
class Translations$settings$prefDescriptions$en {
	Translations$settings$prefDescriptions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Increases legibility for users with low vision'
	String get hyperlegibleFont => 'Increases legibility for users with low vision';

	/// en: '(Not recommended) Allow Saber to connect to servers with self-signed/untrusted certificates'
	String get allowInsecureConnections => '(Not recommended) Allow Saber to connect to servers with self-signed/untrusted certificates';

	/// en: 'For e-ink displays'
	String get preferGreyscale => 'For e-ink displays';

	/// en: 'Clears the whiteboard after you exit the app'
	String get autoClearWhiteboardOnExit => 'Clears the whiteboard after you exit the app';

	/// en: 'Automatically switches back to the pen after using the eraser'
	String get disableEraserAfterUse => 'Automatically switches back to the pen after using the eraser';

	/// en: 'Larger images will be compressed'
	String get maxImageSize => 'Larger images will be compressed';

	late final Translations$settings$prefDescriptions$hideFingerDrawing$en hideFingerDrawing = Translations$settings$prefDescriptions$hideFingerDrawing$en.internal(_root);

	/// en: 'Turn off finger drawing when a stylus is detected'
	String get autoDisableFingerDrawingWhenStylusDetected => 'Turn off finger drawing when a stylus is detected';

	/// en: 'You can always rename notes later'
	String get editorPromptRename => 'You can always rename notes later';

	/// en: 'Show page indicators in exports'
	String get printPageIndicators => 'Show page indicators in exports';

	/// en: 'Auto-save after a short delay, or never'
	String get autosave => 'Auto-save after a short delay, or never';

	/// en: 'How often to update the shape preview'
	String get shapeRecognitionDelay => 'How often to update the shape preview';

	/// en: 'Straightens long lines without having to use the shape pen'
	String get autoStraightenLines => 'Straightens long lines without having to use the shape pen';

	/// en: 'Sets a fixed height for each note preview'
	String get simplifiedHomeLayout => 'Sets a fixed height for each note preview';

	/// en: 'Tell me about updates as soon as they're available'
	String get shouldAlwaysAlertForUpdates => 'Tell me about updates as soon as they\'re available';

	/// en: 'Adjust how stylus pressure maps to stroke width'
	String get penPressureCurve => 'Adjust how stylus pressure maps to stroke width';

	/// en: 'Scribble back and forth over strokes with the pen to erase them'
	String get scribbleToErase => 'Scribble back and forth over strokes with the pen to erase them';

	/// en: 'New notes open with an infinite 2D canvas instead of discrete pages'
	String get defaultInfiniteCanvas => 'New notes open with an infinite 2D canvas instead of discrete pages';

	/// en: 'Gestures, study tape, smooth inking, and elements'
	String get welcomeGuide => 'Gestures, study tape, smooth inking, and elements';

	late final Translations$settings$prefDescriptions$sentry$en sentry = Translations$settings$prefDescriptions$sentry$en.internal(_root);
}

// Path: settings.themeModes
class Translations$settings$themeModes$en {
	Translations$settings$themeModes$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'System'
	String get system => 'System';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';
}

// Path: settings.layoutSizes
class Translations$settings$layoutSizes$en {
	Translations$settings$layoutSizes$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Auto'
	String get auto => 'Auto';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Tablet'
	String get tablet => 'Tablet';
}

// Path: settings.accentColorPicker
class Translations$settings$accentColorPicker$en {
	Translations$settings$accentColorPicker$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pick a color'
	String get pickAColor => 'Pick a color';
}

// Path: settings.reset
class Translations$settings$reset$en {
	Translations$settings$reset$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reset this setting?'
	String get title => 'Reset this setting?';

	/// en: 'Reset'
	String get button => 'Reset';
}

// Path: settings.customDataDir
class Translations$settings$customDataDir$en {
	Translations$settings$customDataDir$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Select'
	String get select => 'Select';

	/// en: 'Selected folder must be empty'
	String get mustBeEmpty => 'Selected folder must be empty';

	/// en: 'Make sure syncing is complete before changing the folder'
	String get mustBeDoneSyncing => 'Make sure syncing is complete before changing the folder';

	/// en: 'This feature is currently only for developers. Using it will likely result in data loss.'
	String get unsupported => 'This feature is currently only for developers. Using it will likely result in data loss.';
}

// Path: login.form
class Translations$login$form$en {
	Translations$login$form$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'By logging in, you agree to the ${linkToPrivacyPolicy(Privacy Policy)}.'
	TextSpan agreeToPrivacyPolicy({required InlineSpanBuilder linkToPrivacyPolicy}) => TextSpan(children: [
		const TextSpan(text: 'By logging in, you agree to the '),
		linkToPrivacyPolicy('Privacy Policy'),
		const TextSpan(text: '.'),
	]);
}

// Path: login.status
class Translations$login$status$en {
	Translations$login$status$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Logged out'
	String get loggedOut => 'Logged out';

	/// en: 'Tap to log in with Nextcloud'
	String get tapToLogin => 'Tap to log in with Nextcloud';

	/// en: 'Hi, $u!'
	String hi({required Object u}) => 'Hi, ${u}!';

	/// en: 'Almost ready for syncing, tap to finish logging in'
	String get almostDone => 'Almost ready for syncing, tap to finish logging in';

	/// en: 'Logged in with Nextcloud'
	String get loggedIn => 'Logged in with Nextcloud';
}

// Path: login.ncLoginStep
class Translations$login$ncLoginStep$en {
	Translations$login$ncLoginStep$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Choose where you want to store your data:'
	String get whereToStoreData => 'Choose where you want to store your data:';

	/// en: 'Saber's Nextcloud server'
	String get saberNcServer => 'Saber\'s Nextcloud server';

	/// en: 'Other Nextcloud server'
	String get otherNcServer => 'Other Nextcloud server';

	/// en: 'Server URL'
	String get serverUrl => 'Server URL';

	/// en: 'Login with Saber'
	String get loginWithSaber => 'Login with Saber';

	/// en: 'Login with Nextcloud'
	String get loginWithNextcloud => 'Login with Nextcloud';

	late final Translations$login$ncLoginStep$loginFlow$en loginFlow = Translations$login$ncLoginStep$loginFlow$en.internal(_root);
}

// Path: login.encLoginStep
class Translations$login$encLoginStep$en {
	Translations$login$encLoginStep$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'To protect your data, please enter your encryption password:'
	String get enterEncPassword => 'To protect your data, please enter your encryption password:';

	/// en: 'New to Saber? Just enter a new encryption password.'
	String get newToSaber => 'New to Saber? Just enter a new encryption password.';

	/// en: 'Encryption password'
	String get encPassword => 'Encryption password';

	/// en: 'Frequently asked questions'
	String get encFaqTitle => 'Frequently asked questions';

	/// en: 'Decryption failed with the provided password. Please try entering it again.'
	String get wrongEncPassword => 'Decryption failed with the provided password. Please try entering it again.';

	/// en: 'Something went wrong connecting to the server. Please try again later.'
	String get connectionFailed => 'Something went wrong connecting to the server. Please try again later.';

	List<dynamic> get encFaq => [
		Translations$login$encLoginStep$encFaq$0$en.internal(_root),
		Translations$login$encLoginStep$encFaq$1$en.internal(_root),
		Translations$login$encLoginStep$encFaq$2$en.internal(_root),
	];
}

// Path: profile.quickLinks
class Translations$profile$quickLinks$en {
	Translations$profile$quickLinks$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Server homepage'
	String get serverHomepage => 'Server homepage';

	/// en: 'Delete account'
	String get deleteAccount => 'Delete account';
}

// Path: profile.faq.0
class Translations$profile$faq$0$en {
	Translations$profile$faq$0$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Will I lose my notes if I log out?'
	String get q => 'Will I lose my notes if I log out?';

	/// en: 'No. Your notes will remain both on your device and on the server. They won't be synced with the server until you log back in. Make sure syncing is complete before logging out so you don't lose any data (see the sync progress on the home screen).'
	String get a => 'No. Your notes will remain both on your device and on the server. They won\'t be synced with the server until you log back in. Make sure syncing is complete before logging out so you don\'t lose any data (see the sync progress on the home screen).';
}

// Path: profile.faq.1
class Translations$profile$faq$1$en {
	Translations$profile$faq$1$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How do I change my Nextcloud password?'
	String get q => 'How do I change my Nextcloud password?';

	/// en: 'Go to your server website and log in. Then go to Settings > Security > Change password. You'll need to log out and log back in to Saber after changing your password.'
	String get a => 'Go to your server website and log in. Then go to Settings > Security > Change password. You\'ll need to log out and log back in to Saber after changing your password.';
}

// Path: profile.faq.2
class Translations$profile$faq$2$en {
	Translations$profile$faq$2$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How do I change my encryption password?'
	String get q => 'How do I change my encryption password?';

	/// en: '0. Make sure syncing is complete (see the sync progress on the home screen). 1. Log out of Saber. 2. Go to your server website and delete your 'Saber' folder. This will delete all your notes from the server. 3. Log back in to Saber. You can choose a new encryption password when logging in. 4. Don't forget to log out and log back in to Saber on your other devices too.'
	String get a => '0. Make sure syncing is complete (see the sync progress on the home screen).\n1. Log out of Saber.\n2. Go to your server website and delete your \'Saber\' folder. This will delete all your notes from the server.\n3. Log back in to Saber. You can choose a new encryption password when logging in.\n4. Don\'t forget to log out and log back in to Saber on your other devices too.';
}

// Path: profile.faq.3
class Translations$profile$faq$3$en {
	Translations$profile$faq$3$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How can I delete my account?'
	String get q => 'How can I delete my account?';

	/// en: 'Tap on the "Delete account" button above, and login if needed. If you are using the official Saber server, your account will be deleted after a 1 week grace period. You can contact me at adilhanney@disroot.org during this period to cancel the deletion. If you are using a third party server, there might not be an option to delete your account: you'll need to consult the server's privacy policy for more information.'
	String get a => 'Tap on the "${_root.profile.quickLinks.deleteAccount}" button above, and login if needed.\nIf you are using the official Saber server, your account will be deleted after a 1 week grace period. You can contact me at adilhanney@disroot.org during this period to cancel the deletion.\nIf you are using a third party server, there might not be an option to delete your account: you\'ll need to consult the server\'s privacy policy for more information.';
}

// Path: editor.toolbar
class Translations$editor$toolbar$en {
	Translations$editor$toolbar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Toggle colors (Ctrl C)'
	String get toggleColors => 'Toggle colors (Ctrl C)';

	/// en: 'Select'
	String get select => 'Select';

	/// en: 'Toggle eraser (Ctrl E)'
	String get toggleEraser => 'Toggle eraser (Ctrl E)';

	/// en: 'Images'
	String get photo => 'Images';

	/// en: 'Text'
	String get text => 'Text';

	/// en: 'Toggle finger drawing (Ctrl F)'
	String get toggleFingerDrawing => 'Toggle finger drawing (Ctrl F)';

	/// en: 'Undo'
	String get undo => 'Undo';

	/// en: 'Redo'
	String get redo => 'Redo';

	/// en: 'Export (Ctrl Shift S)'
	String get export => 'Export (Ctrl Shift S)';

	/// en: 'Export as:'
	String get exportAs => 'Export as:';

	/// en: 'Toggle fullscreen (F11)'
	String get fullscreen => 'Toggle fullscreen (F11)';
}

// Path: editor.pens
class Translations$editor$pens$en {
	Translations$editor$pens$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Fountain pen'
	String get fountainPen => 'Fountain pen';

	/// en: 'Ballpoint pen'
	String get ballpointPen => 'Ballpoint pen';

	/// en: 'Highlighter'
	String get highlighter => 'Highlighter';

	/// en: 'Pencil'
	String get pencil => 'Pencil';

	/// en: 'Shape pen'
	String get shapePen => 'Shape pen';

	/// en: 'Laser pointer'
	String get laserPointer => 'Laser pointer';

	/// en: 'Ruler'
	String get ruler => 'Ruler';
}

// Path: editor.penOptions
class Translations$editor$penOptions$en {
	Translations$editor$penOptions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Size'
	String get size => 'Size';
}

// Path: editor.colors
class Translations$editor$colors$en {
	Translations$editor$colors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Color picker'
	String get colorPicker => 'Color picker';

	/// en: 'Custom $b $h'
	String customBrightnessHue({required Object b, required Object h}) => 'Custom ${b} ${h}';

	/// en: 'Custom $h'
	String customHue({required Object h}) => 'Custom ${h}';

	/// en: 'dark'
	String get dark => 'dark';

	/// en: 'light'
	String get light => 'light';

	/// en: 'Black'
	String get black => 'Black';

	/// en: 'Dark grey'
	String get darkGrey => 'Dark grey';

	/// en: 'Grey'
	String get grey => 'Grey';

	/// en: 'Light grey'
	String get lightGrey => 'Light grey';

	/// en: 'White'
	String get white => 'White';

	/// en: 'Red'
	String get red => 'Red';

	/// en: 'Green'
	String get green => 'Green';

	/// en: 'Cyan'
	String get cyan => 'Cyan';

	/// en: 'Blue'
	String get blue => 'Blue';

	/// en: 'Yellow'
	String get yellow => 'Yellow';

	/// en: 'Purple'
	String get purple => 'Purple';

	/// en: 'Pink'
	String get pink => 'Pink';

	/// en: 'Orange'
	String get orange => 'Orange';

	/// en: 'Pastel red'
	String get pastelRed => 'Pastel red';

	/// en: 'Pastel orange'
	String get pastelOrange => 'Pastel orange';

	/// en: 'Pastel yellow'
	String get pastelYellow => 'Pastel yellow';

	/// en: 'Pastel green'
	String get pastelGreen => 'Pastel green';

	/// en: 'Pastel cyan'
	String get pastelCyan => 'Pastel cyan';

	/// en: 'Pastel blue'
	String get pastelBlue => 'Pastel blue';

	/// en: 'Pastel purple'
	String get pastelPurple => 'Pastel purple';

	/// en: 'Pastel pink'
	String get pastelPink => 'Pastel pink';
}

// Path: editor.imageOptions
class Translations$editor$imageOptions$en {
	Translations$editor$imageOptions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Image options'
	String get title => 'Image options';

	/// en: 'Invertible'
	String get invertible => 'Invertible';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Set as background'
	String get setAsBackground => 'Set as background';

	/// en: 'Remove as background'
	String get removeAsBackground => 'Remove as background';

	/// en: 'Delete'
	String get delete => 'Delete';
}

// Path: editor.selectionBar
class Translations$editor$selectionBar$en {
	Translations$editor$selectionBar$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Duplicate'
	String get duplicate => 'Duplicate';
}

// Path: editor.menu
class Translations$editor$menu$en {
	Translations$editor$menu$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Templates'
	String get templates => 'Templates';

	/// en: 'Clear page $page/$totalPages'
	String clearPage({required Object page, required Object totalPages}) => 'Clear page ${page}/${totalPages}';

	/// en: 'Clear all pages'
	String get clearAllPages => 'Clear all pages';

	/// en: 'Insert page below'
	String get insertPage => 'Insert page below';

	/// en: 'Duplicate page'
	String get duplicatePage => 'Duplicate page';

	/// en: 'Delete page'
	String get deletePage => 'Delete page';

	/// en: 'Line height'
	String get lineHeight => 'Line height';

	/// en: 'Also controls the text size for typed notes'
	String get lineHeightDescription => 'Also controls the text size for typed notes';

	/// en: 'Line thickness'
	String get lineThickness => 'Line thickness';

	/// en: 'Background line thickness'
	String get lineThicknessDescription => 'Background line thickness';

	/// en: 'Background image fit'
	String get backgroundImageFit => 'Background image fit';

	/// en: 'Background pattern'
	String get backgroundPattern => 'Background pattern';

	/// en: 'Import'
	String get import => 'Import';

	/// en: 'Watch for updates on the server'
	String get watchServer => 'Watch for updates on the server';

	/// en: 'Editing is disabled while watching the server'
	String get watchServerReadOnly => 'Editing is disabled while watching the server';

	late final Translations$editor$menu$boxFits$en boxFits = Translations$editor$menu$boxFits$en.internal(_root);
	late final Translations$editor$menu$bgPatterns$en bgPatterns = Translations$editor$menu$bgPatterns$en.internal(_root);
}

// Path: editor.readOnlyBanner
class Translations$editor$readOnlyBanner$en {
	Translations$editor$readOnlyBanner$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Read-only mode'
	String get title => 'Read-only mode';

	/// en: 'You are currently watching for updates on the server. Editing is disabled in this mode.'
	String get watchingServer => 'You are currently watching for updates on the server. Editing is disabled in this mode.';

	/// en: 'Failed to load note. It may be corrupted or still being downloaded.'
	String get corrupted => 'Failed to load note. It may be corrupted or still being downloaded.';
}

// Path: editor.versionTooNew
class Translations$editor$versionTooNew$en {
	Translations$editor$versionTooNew$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This note was edited using a newer version of Saber'
	String get title => 'This note was edited using a newer version of Saber';

	/// en: 'Editing this note may result in some information being lost. Do you want to ignore this and edit it anyway?'
	String get subtitle => 'Editing this note may result in some information being lost. Do you want to ignore this and edit it anyway?';

	/// en: 'Allow editing'
	String get allowEditing => 'Allow editing';
}

// Path: editor.quill
class Translations$editor$quill$en {
	Translations$editor$quill$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Type something here...'
	String get typeSomething => 'Type something here...';
}

// Path: editor.hud
class Translations$editor$hud$en {
	Translations$editor$hud$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unlock zoom'
	String get unlockZoom => 'Unlock zoom';

	/// en: 'Lock zoom'
	String get lockZoom => 'Lock zoom';

	/// en: 'Enable single-finger panning'
	String get unlockSingleFingerPan => 'Enable single-finger panning';

	/// en: 'Disable single-finger panning'
	String get lockSingleFingerPan => 'Disable single-finger panning';

	/// en: 'Unlock panning to horizontal or vertical'
	String get unlockAxisAlignedPan => 'Unlock panning to horizontal or vertical';

	/// en: 'Lock panning to horizontal or vertical'
	String get lockAxisAlignedPan => 'Lock panning to horizontal or vertical';
}

// Path: editor.canvasHud
class Translations$editor$canvasHud$en {
	Translations$editor$canvasHud$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Angle step: $step'
	String angleStep({required Object step}) => 'Angle step: ${step}';

	/// en: 'Iso 30°'
	String get iso30 => 'Iso 30°';

	/// en: 'Hide protractor'
	String get hideProtractor => 'Hide protractor';

	/// en: 'Show protractor'
	String get showProtractor => 'Show protractor';

	/// en: 'Disable snap to grid'
	String get disableSnapToGrid => 'Disable snap to grid';

	/// en: 'Enable snap to grid'
	String get enableSnapToGrid => 'Enable snap to grid';

	/// en: 'Disable snap to angle'
	String get disableSnapToAngle => 'Disable snap to angle';

	/// en: 'Enable snap to angle'
	String get enableSnapToAngle => 'Enable snap to angle';

	/// en: 'Iso'
	String get iso => 'Iso';
}

// Path: editor.layers
class Translations$editor$layers$en {
	Translations$editor$layers$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Layers ($n)'
	String titleWithCount({required Object n}) => 'Layers (${n})';

	/// en: '$n strokes'
	String strokeCount({required Object n}) => '${n} strokes';

	/// en: 'Add Layer'
	String get add => 'Add Layer';

	/// en: 'Hide Layer'
	String get hide => 'Hide Layer';

	/// en: 'Show Layer'
	String get show => 'Show Layer';

	/// en: 'Unlock Layer'
	String get unlock => 'Unlock Layer';

	/// en: 'Lock Layer'
	String get lock => 'Lock Layer';

	/// en: 'Delete Layer'
	String get delete => 'Delete Layer';

	/// en: 'Layers'
	String get title => 'Layers';

	/// en: 'No layers'
	String get none => 'No layers';

	/// en: 'Merge Down'
	String get mergeDown => 'Merge Down';
}

// Path: editor.pageGrid
class Translations$editor$pageGrid$en {
	Translations$editor$pageGrid$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All ($n)'
	String all({required Object n}) => 'All (${n})';

	/// en: 'Bookmarked ($n)'
	String bookmarked({required Object n}) => 'Bookmarked (${n})';

	/// en: 'No bookmarked pages'
	String get noBookmarks => 'No bookmarked pages';

	/// en: 'Star pages to view them here'
	String get starPagesHint => 'Star pages to view them here';

	/// en: 'CURRENT'
	String get current => 'CURRENT';

	/// en: 'Page options'
	String get pageOptions => 'Page options';
}

// Path: editor.presentation
class Translations$editor$presentation$en {
	Translations$editor$presentation$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Flashcard $current / $total · $studied studied'
	String flashcardProgress({required Object current, required Object total, required Object studied}) => 'Flashcard ${current} / ${total}  ·  ${studied} studied';

	/// en: 'Flashcard $n'
	String flashcard({required Object n}) => 'Flashcard ${n}';

	/// en: 'Exit flashcards (Esc)'
	String get exitFlashcards => 'Exit flashcards (Esc)';

	/// en: 'Exit presentation (Esc)'
	String get exitPresentation => 'Exit presentation (Esc)';

	/// en: 'Reset study progress'
	String get resetProgress => 'Reset study progress';

	/// en: 'Don't Know'
	String get dontKnow => 'Don\'t Know';

	/// en: 'Know'
	String get know => 'Know';

	/// en: 'Tap to reveal'
	String get tapToReveal => 'Tap to reveal';
}

// Path: editor.elements
class Translations$editor$elements$en {
	Translations$editor$elements$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete "$name" from your elements collection?'
	String deleteConfirm({required Object name}) => 'Delete "${name}" from your elements collection?';

	/// en: 'Element $n'
	String defaultName({required Object n}) => 'Element ${n}';

	/// en: 'Added "$name" to Elements'
	String added({required Object name}) => 'Added "${name}" to Elements';

	/// en: 'Elements'
	String get title => 'Elements';

	/// en: 'No elements in this collection'
	String get empty => 'No elements in this collection';

	/// en: 'Delete Element?'
	String get deleteTitle => 'Delete Element?';

	/// en: 'Elements (Stickers)'
	String get tooltip => 'Elements (Stickers)';

	/// en: 'Add to Elements'
	String get add => 'Add to Elements';

	/// en: 'Element Name'
	String get nameLabel => 'Element Name';

	/// en: 'Enter name for sticker'
	String get nameHint => 'Enter name for sticker';

	/// en: 'Cannot stamp element on a locked layer'
	String get lockedLayer => 'Cannot stamp element on a locked layer';
}

// Path: editor.tools
class Translations$editor$tools$en {
	Translations$editor$tools$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Stroke Style: $style'
	String strokeStyle({required Object style}) => 'Stroke Style: ${style}';

	/// en: 'Pen Options'
	String get penOptions => 'Pen Options';

	/// en: 'Laser Pointer (Spotlight Mode)'
	String get laserSpotlight => 'Laser Pointer (Spotlight Mode)';

	/// en: 'Fine'
	String get fine => 'Fine';

	/// en: 'Medium'
	String get medium => 'Medium';

	/// en: 'Broad'
	String get broad => 'Broad';

	/// en: 'Tap canvas to add or edit text'
	String get tapToAddText => 'Tap canvas to add or edit text';

	/// en: 'Goodnotes Studio Toolbar'
	String get toolbarLabel => 'Goodnotes Studio Toolbar';

	/// en: 'Draw in Straight Line: ON'
	String get straightLineOn => 'Draw in Straight Line: ON';

	/// en: 'Draw in Straight Line: OFF'
	String get straightLineOff => 'Draw in Straight Line: OFF';

	/// en: 'Scribble to Erase: ON'
	String get scribbleOn => 'Scribble to Erase: ON';

	/// en: 'Scribble to Erase: OFF'
	String get scribbleOff => 'Scribble to Erase: OFF';

	/// en: 'Curve'
	String get curve => 'Curve';

	/// en: 'Pen Settings'
	String get penSettings => 'Pen Settings';
}

// Path: editor.stickyNote
class Translations$editor$stickyNote$en {
	Translations$editor$stickyNote$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit Sticky Note'
	String get editTitle => 'Edit Sticky Note';

	/// en: 'Text:'
	String get textLabel => 'Text:';

	/// en: 'Type your note here...'
	String get hint => 'Type your note here...';

	/// en: 'Color:'
	String get colorLabel => 'Color:';

	/// en: 'Edit Text'
	String get editText => 'Edit Text';

	/// en: 'Sticky notes cannot be downloaded'
	String get cannotDownload => 'Sticky notes cannot be downloaded';

	/// en: 'New Note'
	String get defaultText => 'New Note';
}

// Path: editor.actions
class Translations$editor$actions$en {
	Translations$editor$actions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Cut'
	String get cut => 'Cut';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Paste'
	String get paste => 'Paste';
}

// Path: editor.stickers
class Translations$editor$stickers$en {
	Translations$editor$stickers$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Stickers cannot be downloaded'
	String get cannotDownload => 'Stickers cannot be downloaded';

	/// en: 'Stickers'
	String get title => 'Stickers';
}

// Path: editor.bookmark
class Translations$editor$bookmark$en {
	Translations$editor$bookmark$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Bookmark page'
	String get add => 'Bookmark page';

	/// en: 'Remove bookmark'
	String get remove => 'Remove bookmark';
}

// Path: editor.tape
class Translations$editor$tape$en {
	Translations$editor$tape$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reveal all study tape'
	String get revealAllTooltip => 'Reveal all study tape';

	/// en: 'Conceal all study tape'
	String get concealAllTooltip => 'Conceal all study tape';

	/// en: 'Study Tape (Active Recall)'
	String get tooltip => 'Study Tape (Active Recall)';

	/// en: 'Conceal All'
	String get concealAll => 'Conceal All';

	/// en: 'Reveal All'
	String get revealAll => 'Reveal All';

	/// en: 'Patterns'
	String get patterns => 'Patterns';

	/// en: 'Tape'
	String get short => 'Tape';

	/// en: 'Study Tape'
	String get title => 'Study Tape';

	/// en: 'Study Tape Options'
	String get options => 'Study Tape Options';

	/// en: 'Tape Pattern'
	String get pattern => 'Tape Pattern';

	/// en: 'Solid'
	String get solid => 'Solid';

	/// en: 'Stripes'
	String get stripes => 'Stripes';

	/// en: 'Dots'
	String get dots => 'Dots';

	/// en: 'Grid'
	String get grid => 'Grid';

	/// en: 'Tape Color'
	String get color => 'Tape Color';

	/// en: 'Active Recall Study Controls'
	String get studyControls => 'Active Recall Study Controls';
}

// Path: editor.lasso
class Translations$editor$lasso$en {
	Translations$editor$lasso$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Front'
	String get front => 'Front';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Resize'
	String get resize => 'Resize';

	/// en: 'Color'
	String get color => 'Color';

	/// en: 'Screenshot'
	String get screenshot => 'Screenshot';

	/// en: 'Element'
	String get element => 'Element';

	/// en: 'Arrange'
	String get arrange => 'Arrange';

	/// en: 'Smoothen'
	String get smoothen => 'Smoothen';

	/// en: 'Crop'
	String get crop => 'Crop';

	/// en: 'Handwriting'
	String get handwriting => 'Handwriting';

	/// en: 'Images'
	String get images => 'Images';

	/// en: 'Text Boxes'
	String get textBoxes => 'Text Boxes';

	/// en: 'Lasso Settings'
	String get settings => 'Lasso Settings';

	/// en: 'Lasso Options'
	String get options => 'Lasso Options';

	/// en: 'LASSO TYPE'
	String get typeHeading => 'LASSO TYPE';

	/// en: 'Freehand'
	String get freehand => 'Freehand';

	/// en: 'Rectangular'
	String get rectangular => 'Rectangular';

	/// en: 'INCLUDED IN SELECTION'
	String get includedHeading => 'INCLUDED IN SELECTION';

	/// en: 'Pen, pencil, and highlighter strokes'
	String get handwritingDescription => 'Pen, pencil, and highlighter strokes';

	/// en: 'Photos, stickers, and PDFs'
	String get imagesDescription => 'Photos, stickers, and PDFs';

	/// en: 'Typed notes and text boxes'
	String get textBoxesDescription => 'Typed notes and text boxes';

	/// en: 'Masking tape strips'
	String get tapeDescription => 'Masking tape strips';

	/// en: 'Rect Select'
	String get rectSelect => 'Rect Select';

	/// en: 'Lasso Select'
	String get lassoSelect => 'Lasso Select';

	/// en: 'Lasso Filters'
	String get filters => 'Lasso Filters';

	/// en: 'Crop image'
	String get cropImage => 'Crop image';

	/// en: 'Done cropping'
	String get doneCropping => 'Done cropping';

	/// en: 'Bring to Front'
	String get bringToFront => 'Bring to Front';

	/// en: 'Send to Back'
	String get sendToBack => 'Send to Back';

	/// en: 'Smoothen Handwriting'
	String get smoothenHandwriting => 'Smoothen Handwriting';

	/// en: 'Done Resizing'
	String get doneResizing => 'Done Resizing';

	/// en: 'Screenshot copied to clipboard'
	String get screenshotCopied => 'Screenshot copied to clipboard';
}

// Path: editor.drafting
class Translations$editor$drafting$en {
	Translations$editor$drafting$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Shape Library'
	String get shapeLibrary => 'Shape Library';

	/// en: 'Tap a symbol to insert it onto the canvas.'
	String get shapeLibraryHint => 'Tap a symbol to insert it onto the canvas.';

	/// en: 'Shapes & Drafting'
	String get title => 'Shapes & Drafting';

	/// en: 'Insert geometric primitives & symbols'
	String get shapeLibraryDescription => 'Insert geometric primitives & symbols';

	/// en: 'On-screen straightedge guide'
	String get rulerDescription => 'On-screen straightedge guide';

	/// en: 'Straight Arrow'
	String get straightArrow => 'Straight Arrow';

	/// en: 'Direct pointer arrow'
	String get straightArrowDescription => 'Direct pointer arrow';

	/// en: 'Elbow Connector'
	String get elbowConnector => 'Elbow Connector';

	/// en: 'Orthogonal stepped connector line'
	String get elbowConnectorDescription => 'Orthogonal stepped connector line';

	/// en: 'Curved Connector'
	String get curvedConnector => 'Curved Connector';

	/// en: 'Smooth bezier spline connector'
	String get curvedConnectorDescription => 'Smooth bezier spline connector';

	/// en: 'Dimension Line'
	String get dimensionLine => 'Dimension Line';

	/// en: 'Measured line with real-world dimensions'
	String get dimensionLineDescription => 'Measured line with real-world dimensions';

	/// en: 'Arrow'
	String get arrow => 'Arrow';

	/// en: 'Dimension'
	String get dimension => 'Dimension';

	/// en: 'Drafting & Shapes'
	String get titleAlt => 'Drafting & Shapes';
}

// Path: editor.outline
class Translations$editor$outline$en {
	Translations$editor$outline$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No headings found'
	String get noHeadings => 'No headings found';

	/// en: 'No headings found in document'
	String get noHeadingsInDocument => 'No headings found in document';

	/// en: 'Type headings in text boxes to generate an automatic outline'
	String get howTo => 'Type headings in text boxes to generate an automatic outline';

	/// en: 'Outline'
	String get title => 'Outline';
}

// Path: editor.sheet
class Translations$editor$sheet$en {
	Translations$editor$sheet$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Presentation'
	String get presentation => 'Presentation';

	/// en: 'Flashcards'
	String get flashcards => 'Flashcards';

	/// en: 'Canvas Mode'
	String get canvasMode => 'Canvas Mode';

	/// en: 'Paged'
	String get paged => 'Paged';

	/// en: 'Infinite Canvas (2D)'
	String get infiniteCanvas => 'Infinite Canvas (2D)';

	/// en: 'Bookmark'
	String get bookmark => 'Bookmark';

	/// en: 'Page is bookmarked'
	String get pageIsBookmarked => 'Page is bookmarked';

	/// en: 'Not bookmarked'
	String get notBookmarked => 'Not bookmarked';

	/// en: 'Page Size'
	String get pageSize => 'Page Size';

	/// en: 'Width'
	String get width => 'Width';

	/// en: 'Height'
	String get height => 'Height';

	/// en: 'Square'
	String get square => 'Square';

	/// en: 'Sticky Note'
	String get stickyNote => 'Sticky Note';

	/// en: 'Sticker'
	String get sticker => 'Sticker';
}

// Path: editor.eraser
class Translations$editor$eraser$en {
	Translations$editor$eraser$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Eraser Settings'
	String get settings => 'Eraser Settings';

	/// en: 'Eraser Style'
	String get style => 'Eraser Style';

	/// en: 'Object'
	String get object => 'Object';

	/// en: 'Precision'
	String get precision => 'Precision';

	/// en: 'Auto-Deselect'
	String get autoDeselect => 'Auto-Deselect';

	/// en: 'Return to pen after erasing stroke'
	String get autoDeselectDescription => 'Return to pen after erasing stroke';

	/// en: 'Erase Highlighter Only'
	String get highlighterOnly => 'Erase Highlighter Only';

	/// en: 'Preserve pen ink, arrows, and text'
	String get highlighterOnlyDescription => 'Preserve pen ink, arrows, and text';

	/// en: 'Erase Tape Only'
	String get tapeOnly => 'Erase Tape Only';

	/// en: 'Only erase study tape strips'
	String get tapeOnlyDescription => 'Only erase study tape strips';

	/// en: 'Clear Page'
	String get clearPage => 'Clear Page';

	/// en: 'Highlighter Only'
	String get highlighterOnlyShort => 'Highlighter Only';

	/// en: 'Entire Stroke'
	String get entireStroke => 'Entire Stroke';

	/// en: 'Clear Page?'
	String get clearPageTitle => 'Clear Page?';

	/// en: 'This will delete all ink, shapes, and media on this page.'
	String get clearPageDescription => 'This will delete all ink, shapes, and media on this page.';
}

// Path: editor.header
class Translations$editor$header$en {
	Translations$editor$header$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Documents'
	String get documents => 'Documents';

	/// en: 'Infinite'
	String get infinite => 'Infinite';

	/// en: 'Hand Reading Mode (Drawing disabled)'
	String get readingMode => 'Hand Reading Mode (Drawing disabled)';

	/// en: 'Editing Mode (Draw with Pen/Finger)'
	String get editingMode => 'Editing Mode (Draw with Pen/Finger)';

	/// en: 'More Options'
	String get moreOptions => 'More Options';
}

// Path: editor.palette
class Translations$editor$palette$en {
	Translations$editor$palette$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pen Color Slot'
	String get penSlot => 'Pen Color Slot';

	/// en: 'Highlighter Color Slot'
	String get highlighterSlot => 'Highlighter Color Slot';

	/// en: 'Adjust Stroke Width'
	String get adjustWidth => 'Adjust Stroke Width';

	/// en: 'Set Width'
	String get setWidth => 'Set Width';
}

// Path: onboarding.paper
class Translations$onboarding$paper$en {
	Translations$onboarding$paper$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Silky Smooth Digital Paper'
	String get title => 'Silky Smooth Digital Paper';

	/// en: 'Write and sketch with fountain, ballpoint, pencil, and highlighter tools. Featuring customizable pressure curves and paper templates (grid, dotted, cornell, isometric).'
	String get description => 'Write and sketch with fountain, ballpoint, pencil, and highlighter tools. Featuring customizable pressure curves and paper templates (grid, dotted, cornell, isometric).';

	/// en: 'Paper Templates'
	String get tagTemplates => 'Paper Templates';

	/// en: 'Smooth Curves'
	String get tagCurves => 'Smooth Curves';

	/// en: 'Pressure Sensitive'
	String get tagPressure => 'Pressure Sensitive';
}

// Path: onboarding.gestures
class Translations$onboarding$gestures$en {
	Translations$onboarding$gestures$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Magic Stylus Gestures'
	String get title => 'Magic Stylus Gestures';

	/// en: 'Scribble back and forth over handwriting, text, or stickers to erase them instantly! Circle anything to lasso select, move, scale, rotate, and recolor.'
	String get description => 'Scribble back and forth over handwriting, text, or stickers to erase them instantly! Circle anything to lasso select, move, scale, rotate, and recolor.';

	/// en: 'Two-Finger Tap Undo'
	String get tagUndo => 'Two-Finger Tap Undo';

	/// en: 'Circle to Select'
	String get tagCircle => 'Circle to Select';

	/// en: 'Scribble to Erase'
	String get tagScribble => 'Scribble to Erase';
}

// Path: onboarding.tape
class Translations$onboarding$tape$en {
	Translations$onboarding$tape$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Study Tape & Active Recall'
	String get title => 'Study Tape & Active Recall';

	/// en: 'Conceal answers, formulas, and diagrams with study tape. Tap anytime to reveal or conceal, making revision fast and effortless.'
	String get description => 'Conceal answers, formulas, and diagrams with study tape. Tap anytime to reveal or conceal, making revision fast and effortless.';

	/// en: 'Study Mode'
	String get tagStudy => 'Study Mode';

	/// en: 'Tap to Reveal'
	String get tagReveal => 'Tap to Reveal';

	/// en: 'Active Recall'
	String get tagRecall => 'Active Recall';
}

// Path: onboarding.elements
class Translations$onboarding$elements$en {
	Translations$onboarding$elements$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Elements & Infinite Canvas'
	String get title => 'Elements & Infinite Canvas';

	/// en: 'Collect stickers, diagrams, and shapes in the Elements tray. Switch effortlessly between structured pages and an infinite freeform canvas.'
	String get description => 'Collect stickers, diagrams, and shapes in the Elements tray. Switch effortlessly between structured pages and an infinite freeform canvas.';

	/// en: 'Infinite Workspace'
	String get tagWorkspace => 'Infinite Workspace';

	/// en: 'Multi-Layer Canvas'
	String get tagLayers => 'Multi-Layer Canvas';

	/// en: 'Elements Tray'
	String get tagTray => 'Elements Tray';
}

// Path: sentry.consent.description
class Translations$sentry$consent$description$en {
	Translations$sentry$consent$description$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Would you like to automatically report unexpected errors? This helps me identify and fix issues faster.'
	String get question => 'Would you like to automatically report unexpected errors? This helps me identify and fix issues faster.';

	/// en: 'The reports may contain information about the error and your device. I've made every effort to filter out personal data but some may remain.'
	String get scope => 'The reports may contain information about the error and your device. I\'ve made every effort to filter out personal data but some may remain.';

	/// en: 'If you grant consent, error reporting will be enabled after you restart the app.'
	String get currentlyOff => 'If you grant consent, error reporting will be enabled after you restart the app.';

	/// en: 'If you revoke consent, please restart the app to disable error reporting.'
	String get currentlyOn => 'If you revoke consent, please restart the app to disable error reporting.';

	/// en: 'Learn more in the ${link(privacy policy)}.'
	TextSpan learnMoreInPrivacyPolicy({required InlineSpanBuilder link}) => TextSpan(children: [
		const TextSpan(text: 'Learn more in the '),
		link('privacy policy'),
		const TextSpan(text: '.'),
	]);
}

// Path: sentry.consent.answers
class Translations$sentry$consent$answers$en {
	Translations$sentry$consent$answers$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'Ask me later'
	String get later => 'Ask me later';
}

// Path: settings.prefDescriptions.hideFingerDrawing
class Translations$settings$prefDescriptions$hideFingerDrawing$en {
	Translations$settings$prefDescriptions$hideFingerDrawing$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Prevents accidental toggling'
	String get shown => 'Prevents accidental toggling';

	/// en: 'Finger drawing is fixed as enabled'
	String get fixedOn => 'Finger drawing is fixed as enabled';

	/// en: 'Finger drawing is fixed as disabled'
	String get fixedOff => 'Finger drawing is fixed as disabled';
}

// Path: settings.prefDescriptions.sentry
class Translations$settings$prefDescriptions$sentry$en {
	Translations$settings$prefDescriptions$sentry$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'Inactive'
	String get inactive => 'Inactive';

	/// en: 'Active until you restart the app'
	String get activeUntilRestart => 'Active until you restart the app';

	/// en: 'Inactive until you restart the app'
	String get inactiveUntilRestart => 'Inactive until you restart the app';
}

// Path: login.ncLoginStep.loginFlow
class Translations$login$ncLoginStep$loginFlow$en {
	Translations$login$ncLoginStep$loginFlow$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Please authorize Saber to access your Nextcloud account'
	String get pleaseAuthorize => 'Please authorize Saber to access your Nextcloud account';

	/// en: 'Please follow the prompts in the Nextcloud interface'
	String get followPrompts => 'Please follow the prompts in the Nextcloud interface';

	/// en: 'Login page didn't open? Click here'
	String get browserDidntOpen => 'Login page didn\'t open? Click here';
}

// Path: login.encLoginStep.encFaq.0
class Translations$login$encLoginStep$encFaq$0$en {
	Translations$login$encLoginStep$encFaq$0$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What is an encryption password? Why use two passwords?'
	String get q => 'What is an encryption password? Why use two passwords?';

	/// en: 'The Nextcloud password is used to access the cloud. The encryption password "scrambles" your data before it ever reaches the cloud. Even if someone gains access to your Nextcloud account, your notes will remain safe and encrypted with a separate password. This provides you a second layer of security to protect your data. No-one can access your notes on the server without your encryption password, but this also means that if you forget your encryption password, you will lose access to your data.'
	String get a => 'The Nextcloud password is used to access the cloud. The encryption password "scrambles" your data before it ever reaches the cloud.\nEven if someone gains access to your Nextcloud account, your notes will remain safe and encrypted with a separate password. This provides you a second layer of security to protect your data.\nNo-one can access your notes on the server without your encryption password, but this also means that if you forget your encryption password, you will lose access to your data.';
}

// Path: login.encLoginStep.encFaq.1
class Translations$login$encLoginStep$encFaq$1$en {
	Translations$login$encLoginStep$encFaq$1$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'I haven't set an encryption password yet. Where do I get it?'
	String get q => 'I haven\'t set an encryption password yet. Where do I get it?';

	/// en: 'Choose a new encryption password and enter it above. Saber will generate your encryption keys from this password automatically.'
	String get a => 'Choose a new encryption password and enter it above.\nSaber will generate your encryption keys from this password automatically.';
}

// Path: login.encLoginStep.encFaq.2
class Translations$login$encLoginStep$encFaq$2$en {
	Translations$login$encLoginStep$encFaq$2$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Can I use the same password as my Nextcloud account?'
	String get q => 'Can I use the same password as my Nextcloud account?';

	/// en: 'Yes, but keep in mind that it would be easier for the server administrator or someone else to access your notes if they gain access to your Nextcloud account.'
	String get a => 'Yes, but keep in mind that it would be easier for the server administrator or someone else to access your notes if they gain access to your Nextcloud account.';
}

// Path: editor.menu.boxFits
class Translations$editor$menu$boxFits$en {
	Translations$editor$menu$boxFits$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Stretch'
	String get fill => 'Stretch';

	/// en: 'Cover'
	String get cover => 'Cover';

	/// en: 'Contain'
	String get contain => 'Contain';
}

// Path: editor.menu.bgPatterns
class Translations$editor$menu$bgPatterns$en {
	Translations$editor$menu$bgPatterns$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Blank'
	String get none => 'Blank';

	/// en: 'College-ruled'
	String get college => 'College-ruled';

	/// en: 'College-ruled (Reverse)'
	String get collegeRtl => 'College-ruled (Reverse)';

	/// en: 'Lined'
	String get lined => 'Lined';

	/// en: 'Grid'
	String get grid => 'Grid';

	/// en: 'Dots'
	String get dots => 'Dots';

	/// en: 'Staffs'
	String get staffs => 'Staffs';

	/// en: 'Tablature'
	String get tablature => 'Tablature';

	/// en: 'Cornell'
	String get cornell => 'Cornell';
}
