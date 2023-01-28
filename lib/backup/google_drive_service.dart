import 'dart:convert';
import 'dart:io' as io;

// import 'package:googleapis/drive/v2.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:retail_bill/security/google_auth_client.dart';

class GoogleDriveService {

  // make this a singleton class
  GoogleDriveService._privateConstructor();
  static final GoogleDriveService instance = GoogleDriveService._privateConstructor();
  
  signIn.GoogleSignInAccount ?account;
  late Map<String, String> authHeaders;
  late GoogleAuthClient authenticateClient;
  late drive.DriveApi driveApi;
  bool initialized = false;

Future<void> initService() async {
    final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveAppdataScope]);
    account = await googleSignIn.signIn() as signIn.GoogleSignInAccount; 
    print("User account $account");

    authHeaders = await account!.authHeaders;
    authenticateClient = GoogleAuthClient(authHeaders);
    driveApi = drive.DriveApi(authenticateClient);
    print('init completed');
    initialized = true;
}

  Future<void> getUser() async {
    // if(initialized == false)
     await initService();
    // final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveFileScope]);
    // account = await googleSignIn.signIn() as signIn.GoogleSignInAccount; 
    // print("User account $account");

    // authHeaders = await account.authHeaders;
    // authenticateClient = GoogleAuthClient(authHeaders);
    // driveApi = drive.DriveApi(authenticateClient);

    // DatabaseHelper dbHelper = DatabaseHelper.instance;
    // List<Map<String, dynamic>> data = await dbHelper.queryAllRows();
    // uploadFile(data);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<io.File> _localFile(String filename) async {
    final path = await _localPath;
    return io.File('$path/$filename.json');
  }

  Future<io.File> createJsonFile(List<Map<String, dynamic>> bills, String filename) async {
    final file = await _localFile(filename);
    print(file.path);
    String data = jsonEncode(bills);
    // String data = "testing";
    // print(data);
    // Write the file
    file.writeAsStringSync(data, flush: true);

    // String contents = await file.readAsString();
    // var jsonResponse = jsonDecode(contents);
    // print(contents);

    return file;
  }

  void uploadFile(List<Map<String, dynamic>> bills) async {
     var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate);
    
    // io.File file = await createJsonFile(bills, formattedDate);
    // final file = await _localFile(formattedDate);

    // final Stream<List<int>> mediaStream =
    // Future.value([104, 105]).asStream().asBroadcastStream();
    // print(file.lengthSync());
    
    String data = jsonEncode(bills);
    // String data = "Hi";
    // List<int> encodedData = utf8.encode(data);
    final Stream<List<int>> mediaStream =
    Future.value(data.codeUnits).asStream().asBroadcastStream();
    
    var media = new drive.Media(mediaStream, data.length);
    var driveFile = new drive.File();
    driveFile.trashed = true;
    driveFile.name = formattedDate;
    driveFile.modifiedTime = DateTime.now().toUtc();
    // driveFile.spaces = ["appDataFolder"];
    driveFile.parents = ["appDataFolder"];
    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    
    print("Upload result: $result");
  }

  Future<List<drive.File>?> getAllFiles() async{
    print(initialized);
    if(initialized == false) await initService();

    final filelist = await driveApi.files.list(spaces: "appDataFolder");
    print(jsonEncode(filelist));
    return filelist.files;
    // return  (await driveApi.files.list()).items;
  }

}