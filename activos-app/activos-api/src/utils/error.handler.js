/* Esta Función la hice para que llamemos en la parte del catch de un try-catch.
    De esta forma si el error es de los que nosotros definimos en la base de datos,
    se devulve el mensaje definido en SQL.
    Si no quieres que se devuelva ese mensaje, no es obligatorio usarla.
*/
const catchSQL45000 = async (res, error,mensaje ="error al realizar la acción") => {
    if (error?.sqlState === '45000') {
        return res.status(422).json({
            message: mensaje,
            error: error.sqlMessage
        });
    }
};

export default catchSQL45000;