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
    console.log('conectando a la base de datos...')
    const connection = await mysql.createConnection({
        host: process.env.DB_HOSTNAME,
        user: 'root',
        database: process.env.MYSQL_DATABASE,
        password: process.env.MYSQL_ROOT_PASSWORD
    })
    try {
        const [results,fields] = await connection.query(
            'SELECT * FROM `Usuarios`  '
        );
        console.log('test')
        console.log(results); // results contains rows returned by server
        console.log(fields); // fields contains extra meta data about results, if available
    } catch (error) {  
        console.log('error conectandose a la base de datos:')
        console.log(error);
    }
}
export {
    connectarMySQL,
    pool
};
