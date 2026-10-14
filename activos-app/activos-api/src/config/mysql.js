import mysql from  'mysql2/promise'


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
            'SELECT * FROM `Activos` WHERE idActivo=1 '
        );
        console.log('test')
        console.log(results); // results contains rows returned by server
        console.log(fields); // fields contains extra meta data about results, if available
    } catch (error) { 
        console.log('error conectandose a la base de datos:')
        console.log(error);
    }
}
export {connectarMySQL};
