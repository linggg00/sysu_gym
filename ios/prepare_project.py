"""Generate the checked-in Xcode project and reuse the Android app icon artwork."""
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent / "SuixinYueIOS"
PROJECT = ROOT / "SuixinYueIOS.xcodeproj"
PROJECT.mkdir(exist_ok=True)
objects = {}


def ident(name):
    return hashlib.sha1(name.encode()).hexdigest()[:24].upper()


def add(object_name, isa, **values):
    key = ident(object_name)
    objects[key] = {"isa": isa, **values}
    return key


def plist(value):
    if isinstance(value, dict):
        return "{\n" + "\n".join(f"{json.dumps(k)} = {plist(v)};" for k, v in value.items()) + "\n}"
    if isinstance(value, list):
        return "(\n" + "".join(plist(v) + ",\n" for v in value) + ")"
    if isinstance(value, int):
        return str(value)
    return json.dumps(value, ensure_ascii=False)


sources = []
files = []
for name in ["SuixinYueApp.swift", "ContentView.swift"]:
    ref = add(name, "PBXFileReference", lastKnownFileType="sourcecode.swift", path=name, sourceTree="<group>")
    files.append(ref)
    sources.append(add(name + " build", "PBXBuildFile", fileRef=ref))
assets = add("assets", "PBXFileReference", lastKnownFileType="folder.assetcatalog", path="Assets.xcassets", sourceTree="<group>")
files.append(assets)
resource = add("assets build", "PBXBuildFile", fileRef=assets)
product = add("product", "PBXFileReference", explicitFileType="wrapper.application", path="SuixinYueIOS.app", sourceTree="BUILT_PRODUCTS_DIR", includeInIndex=0)
products = add("products", "PBXGroup", children=[product], name="Products", sourceTree="<group>")
group = add("main group", "PBXGroup", children=files + [products], sourceTree="<group>")
source_phase = add("sources", "PBXSourcesBuildPhase", buildActionMask=2147483647, files=sources, runOnlyForDeploymentPostprocessing=0)
framework_phase = add("frameworks", "PBXFrameworksBuildPhase", buildActionMask=2147483647, files=[], runOnlyForDeploymentPostprocessing=0)
resource_phase = add("resources", "PBXResourcesBuildPhase", buildActionMask=2147483647, files=[resource], runOnlyForDeploymentPostprocessing=0)
project_configs, target_configs = [], []
for config in ["Debug", "Release"]:
    project_settings = dict(CLANG_ENABLE_MODULES="YES", CLANG_ENABLE_OBJC_ARC="YES", SDKROOT="iphoneos", IPHONEOS_DEPLOYMENT_TARGET="16.4", SWIFT_VERSION="5.0", DEBUG_INFORMATION_FORMAT="dwarf" if config == "Debug" else "dwarf-with-dsym")
    target_settings = dict(ASSETCATALOG_COMPILER_APPICON_NAME="AppIcon", CODE_SIGN_STYLE="Automatic", CURRENT_PROJECT_VERSION="1", GENERATE_INFOPLIST_FILE="YES", INFOPLIST_KEY_CFBundleDisplayName="体育场馆预订系统", INFOPLIST_KEY_ITSAppUsesNonExemptEncryption="NO", INFOPLIST_KEY_LSApplicationCategoryType="public.app-category.sports", INFOPLIST_KEY_UIApplicationSceneManifest_Generation="YES", INFOPLIST_KEY_UILaunchScreen_Generation="YES", INFOPLIST_KEY_UIUserInterfaceStyle="Light", INFOPLIST_KEY_UISupportedInterfaceOrientations="UIInterfaceOrientationPortrait", MARKETING_VERSION="1.0", PRODUCT_BUNDLE_IDENTIFIER="com.suixinyue.sports", PRODUCT_NAME="$(TARGET_NAME)", SUPPORTED_PLATFORMS="iphoneos iphonesimulator", SUPPORTS_MACCATALYST="NO", SWIFT_EMIT_LOC_STRINGS="YES", TARGETED_DEVICE_FAMILY="1", LD_RUNPATH_SEARCH_PATHS=["$(inherited)", "@executable_path/Frameworks"])
    if config == "Debug":
        target_settings.update(SWIFT_OPTIMIZATION_LEVEL="-Onone", SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG", ONLY_ACTIVE_ARCH="YES")
    else:
        target_settings.update(SWIFT_COMPILATION_MODE="wholemodule", SWIFT_OPTIMIZATION_LEVEL="-O", VALIDATE_PRODUCT="YES")
    project_configs.append(add("project " + config, "XCBuildConfiguration", buildSettings=project_settings, name=config))
    target_configs.append(add("target " + config, "XCBuildConfiguration", buildSettings=target_settings, name=config))
project_list = add("project configs", "XCConfigurationList", buildConfigurations=project_configs, defaultConfigurationIsVisible=0, defaultConfigurationName="Release")
target_list = add("target configs", "XCConfigurationList", buildConfigurations=target_configs, defaultConfigurationIsVisible=0, defaultConfigurationName="Release")
target = add("target", "PBXNativeTarget", buildConfigurationList=target_list, buildPhases=[source_phase, framework_phase, resource_phase], buildRules=[], dependencies=[], name="SuixinYueIOS", productName="SuixinYueIOS", productReference=product, productType="com.apple.product-type.application")
project = add("project", "PBXProject", attributes={"BuildIndependentTargetsInParallel": "YES", "LastUpgradeCheck": "1600", "TargetAttributes": {target: {"CreatedOnToolsVersion": "16.0"}}}, buildConfigurationList=project_list, compatibilityVersion="Xcode 14.0", developmentRegion="zh-Hans", hasScannedForEncodings=0, knownRegions=["zh-Hans", "en", "Base"], mainGroup=group, productRefGroup=products, projectDirPath="", projectRoot="", targets=[target])
(PROJECT / "project.pbxproj").write_text("// !$*UTF8*$!\n" + plist(dict(archiveVersion=1, classes={}, objectVersion=56, objects=objects, rootObject=project)) + "\n", encoding="utf-8")
schemes = PROJECT / "xcshareddata" / "xcschemes"
schemes.mkdir(parents=True, exist_ok=True)
reference = f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target}" BuildableName="SuixinYueIOS.app" BlueprintName="SuixinYueIOS" ReferencedContainer="container:SuixinYueIOS.xcodeproj"/>'
(schemes / "SuixinYueIOS.xcscheme").write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.3">
  <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{reference}</BuildActionEntry></BuildActionEntries></BuildAction>
  <TestAction buildConfiguration="Debug" shouldUseLaunchSchemeArgsEnv="YES"/>
  <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference}</BuildableProductRunnable></LaunchAction>
  <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference}</BuildableProductRunnable></ProfileAction>
  <AnalyzeAction buildConfiguration="Debug"/>
  <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''', encoding="utf-8")

assets_dir = ROOT / "Assets.xcassets"
icon_dir = assets_dir / "AppIcon.appiconset"
icon_dir.mkdir(parents=True, exist_ok=True)
(assets_dir / "Contents.json").write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2), encoding="utf-8")
image = Image.new("RGB", (1024, 1024), "#2B2B2B")
draw = ImageDraw.Draw(image)
for left, top, right, bottom in [(34, 34, 74, 42), (34, 50, 74, 58), (34, 66, 60, 74)]:
    draw.rectangle(tuple(round(v * 1024 / 108) for v in (left, top, right, bottom)), fill="white")
image.save(icon_dir / "AppIcon.png")
(icon_dir / "Contents.json").write_text(json.dumps({"images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}], "info": {"author": "xcode", "version": 1}}, indent=2), encoding="utf-8")
print("Generated Xcode project, shared scheme, and app icon.")
