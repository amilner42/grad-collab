import errorHandler from "errorhandler";
import https from "https";
import http from "http";
import fs from "fs";
import app from "./app";
import { IS_PROD } from "./util/secrets";


// finally, let's start our server...
if (IS_PROD) {
  const privateKey  = fs.readFileSync("./certs/vivadoc-private-key.pem", "utf8");
  const certificate = fs.readFileSync("./certs/vivadoc.cert", "utf8");
  const credentials = { key: privateKey, cert: certificate };

  const httpsServer = https.createServer(credentials, app);
  httpsServer.listen(app.get("port"));
} else {
  const httpServer = http.createServer(app);
  httpServer.listen(app.get("port"));
}
