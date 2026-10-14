import app from "./app.js";
import { connectarMySQL } from "./config/mysql.js";

const startServer = async () => {
    try {
        await connectarMySQL();
        app.on("error",(error) => {
            console.log("ERROR", error)
            throw error;
        });
        app.listen(3000,'0.0.0.0',()=>{
            console.log('El servidor activos-api se encuentra funcionando sobre el puerto '+3000);
        })
    } catch (error) {
        console.log(error)
    }
}
startServer();