import mysql from  'mysql2/promise'


const connectarMySQL = async () => {
    console.log('conectando a la base de datos...')
    const connection = await mysql.createConnection({
        host: 'activos-db',
        user: 'root',
        database: 'GestionDeActivos',
        password: 'example'
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
