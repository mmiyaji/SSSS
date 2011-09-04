package {
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	
	import flash.desktop.Updater;
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class UpdateController extends UIComponent {
		private var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI;
		public var VERSION_URL:String;

		public function get applicationUpdater():ApplicationUpdaterUI{
			return appUpdater;
		}
		public function UpdateController() {
			super();
			appUpdater.configurationFile = new File("app:/update.xml");
			appUpdater.addEventListener(ErrorEvent.ERROR, onError);
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, 
				function (event:UpdateEvent):void {
					checkForUpdate();
				}
			);
			appUpdater.initialize();
			this.VERSION_URL = appUpdater.updateURL;
			trace("TRACE",appUpdater.updateURL,appUpdater.currentVersion);
//			trace(appUpdater.);
			checkUpdate();
		}
		
		private function onError(ev:ErrorEvent):void {
			trace("error",ev);
		}
		
		public function checkForUpdate():void {
			appUpdater.checkNow();
			trace("check now",appUpdater.previousVersion);
		}
		
		private var completedFunction:Function;
		public function checkUpdate():void {
			var versionLoader:URLLoader = new URLLoader();
			versionLoader.addEventListener(Event.COMPLETE, onVersionXmlLoaded);
			versionLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			versionLoader.load(new URLRequest(VERSION_URL));    
		}
		
//		/* エラー発生時 */
//		private function onError(event:IOErrorEvent):void {
//			completedFunction();
//		}
		
		/* VersionXMLをダウンロードしてVersionをチェック */
		private var remoteVersion:String;
		private var updateWindow:UpdateWindow;
		private function onVersionXmlLoaded(event:Event):void {
			var xml:XML = new XML(event.target.data);
			remoteVersion = xml.version;
			trace(xml,xml.version,xml.update,xml.update.xml);
			var appVersion:String = appUpdater.currentVersion;
			var description:String = xml.description;
			var updateUrl:String = xml.url;
			if (remoteVersion != appVersion) {
//				Alert.show("It is possible to update it to a new version. \n" +
//					"Do you update it?\n\n" +
//					"Now version: " + appVersion + "\n" +
//					"New version: " + remoteVersion,
//					'Confirm',
//					Alert.YES | Alert.NO, null, 
//					function (event:CloseEvent):void {
//						if (event.detail == Alert.YES) {
//							downloadNewPackage(xml.url);
//						} else {
//							completedFunction();
//						}
//					}
//				);
				updateWindow = new UpdateWindow();
				updateWindow.init(remoteVersion, appVersion, description,updateUrl, this);
//				updateWindow.open(true);
			} else {
				completedFunction();
			}
		}
	}
}