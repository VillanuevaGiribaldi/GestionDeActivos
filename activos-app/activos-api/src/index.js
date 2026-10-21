import app from "./app.js";
import { connectarMySQL } from "./config/mysql.js";
import {setTimeout} from 'node:timers/promises';

const startServer = async () => {
        
        try {
            await connectarMySQL();
            app.on("error",(error) => {
                console.log("ERROR", error)
                throw error;
            });
            app.listen(process.env.API_PORT,'0.0.0.0',()=>{
                console.log('El servidor activos-api se encuentra funcionando sobre el  puerto '+process.env.API_PORT);
            })
           
        } catch (error) { 
            console.log(error)
        }
    
}
startServer();