--- TiddlyWiki5/boot/boot.js	2022-12-19 19:47:55.000000000 +0100
+++ TiddlyLite/boot/boot.js	2023-02-24 19:32:44.728728724 +0100
@@ -741,50 +741,6 @@
 	}
 }
 
-/*
-Crypto helper object for encrypted content. It maintains the password text in a closure, and provides methods to change
-the password, and to encrypt/decrypt a block of text
-*/
-$tw.utils.Crypto = function() {
-	var sjcl = $tw.node ? (global.sjcl || require("./sjcl.js")) : window.sjcl,
-		currentPassword = null,
-		callSjcl = function(method,inputText,password) {
-			password = password || currentPassword;
-			var outputText;
-			try {
-				if(password) {
-					outputText = sjcl[method](password,inputText);
-				}
-			} catch(ex) {
-				console.log("Crypto error:" + ex);
-				outputText = null;
-			}
-			return outputText;
-		};
-	this.setPassword = function(newPassword) {
-		currentPassword = newPassword;
-		this.updateCryptoStateTiddler();
-	};
-	this.updateCryptoStateTiddler = function() {
-		if($tw.wiki) {
-			var state = currentPassword ? "yes" : "no",
-				tiddler = $tw.wiki.getTiddler("$:/isEncrypted");
-			if(!tiddler || tiddler.fields.text !== state) {
-				$tw.wiki.addTiddler(new $tw.Tiddler({title: "$:/isEncrypted", text: state}));
-			}
-		}
-	};
-	this.hasPassword = function() {
-		return !!currentPassword;
-	}
-	this.encrypt = function(text,password) {
-		return callSjcl("encrypt",text,password);
-	};
-	this.decrypt = function(text,password) {
-		return callSjcl("decrypt",text,password);
-	};
-};
-
 /////////////////////////// Module mechanism
 
 /*
@@ -2650,8 +2606,6 @@
 /////////////////////////// Main boot function to decrypt tiddlers and then startup
 
 $tw.boot.boot = function(callback) {
-	// Initialise crypto object
-	$tw.crypto = new $tw.utils.Crypto();
 	// Initialise password prompter
 	if($tw.browser && !$tw.node) {
 		$tw.passwordPrompt = new $tw.utils.PasswordPrompt();
