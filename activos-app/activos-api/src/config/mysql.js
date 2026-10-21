import mysql from  'mysql2/promise'

const pool = mysql.createPool({
  host: process.env.DB_HOSTNAME,
  user: 'root',
  database:  process.env.MYSQL_DATABASE,
  password: process.env.MYSQL_ROOT_PASSWORD,
  waitForConnections: true,
  connectionLimit: 10,
  maxIdle: 10, // max idle connections, the default value is the same as `connectionLimit`
  idleTimeout: 60000, // idle connections timeout, in milliseconds, the default value 60000
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
});

const connectarMySQL = async () => {
    
    const maximosIntentos = 5
    const espera = 1000
        
    for (let intentos = 0; intentos < maximosIntentos+1; intentos++) {
        try {
            console.log('conectando a la base de datos...')
            const connection = await mysql.createConnection({
                host: process.env.DB_HOSTNAME,
                user: 'root',
                database: process.env.MYSQL_DATABASE,
                password: process.env.MYSQL_ROOT_PASSWORD
            })
            intentos=maximosIntentos
        } catch (error) {
            if (intentos==maximosIntentos) {
                throw error
            }
            console.log("error al conectar a la base de datos:\n "+error+"\n"+(maximosIntentos-intentos)+" restantes. Se reintentará la conexión en 2 segundos.")
            await new Promise((resolve) => setTimeout(resolve, espera));
        }
    }
        
        
    
    
    
}
export {
    connectarMySQL,
    pool
};
