import Persona from '../models/personas.models.js';
import catchSQL45000 from '../utils/error.handler.js';

const nuevaPersona = async (req, res) => {
    try {
        const persona = Persona.fromObject(req.body.persona);
        const resultado = await persona.save();
        
        return res.status(201).json({
            mensaje: 'Persona creada exitosamente',
            datos: resultado
        });

    } catch (error) {
        console.error('Error al guardar la persona:', error);
        if (!catchSQL45000(res, error, "No se pudo crear la persona")) {
            return res.status(500).json({
                message: 'error al crear la persona'
            });
        }
    }
}

const getPersona = async (req,res) => {
    try {
        const personaData = await Persona.buscarPorId(parseInt(req.params.id))
        if (!personaData) {
            res.status(404).json({
                message: "No existe la persona indicada"
            })
        }
        res.status(200).json({
            persona: personaData,
            message: "Se encontró la persona indicada"
        })
    } catch (error) {
        catchSQL45000(res, error,"No se pudo encontrar la persona")
        if (!catchSQL45000(res, error, "No se pudo encontrar la persona")) {
            return res.status(500).json({
                message: "Error interno al buscar a la persona"
            });
        }
    }
}

const bajaPersona = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        console.log(`Dando de baja a la Persona ${idUrl}`);
        
        await Persona.darDeBaja(idUrl);
        
        return res.status(200).json({
            message: "Persona dado de baja exitosamente"
        });

    } catch (error) {
        console.error('Error al dar de baja la Persona:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de baja la persona")) {
            return res.status(500).json({
                message: 'error al dar de baja la persona'
            });
        }
    }
}

const altaPersona = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        console.log(`Dando de alta al Persona ${idUrl}`);
        
        await Persona.darDeAlta(idUrl);
        
        return res.status(201).json({
            message: "Persona dado de alta exitosamente"
        });

    } catch (error) {
        console.error('Error al dar de alta la persona:', error);
        if (!catchSQL45000(res, error, "No se pudo dar de alta la persona")) {
            return res.status(500).json({
                message: 'error al dar de alta la persona'
            });
        }
    }
}

const modificarPersona = async (req, res) => {
    try {
        const idUrl = parseInt(req.params.id);
        // Validación de correspondencia de IDs
        if (idUrl !== parseInt(req.body.persona.idPersona)) {
            return res.status(400).json({
                message: "Los IDs de la URL y del cuerpo no se corresponden"
            });
        }
        console.log(`Modificando la persona ${idUrl}`);

        // Instanciación del usuario a partir del cuerpo
        const persona = Persona.fromObject(req.body.persona);
        
        // Ejecución de la modificación en BD
        await persona.modificar();
        
        return res.status(200).json({
            message: "Persona modificada exitosamente"
        });

    } catch (error) {
        console.error('Error al modificar la persona:', error);
        if (!catchSQL45000(res, error,"No se pudo modificar la persona")){
            return res.status(500).json({
            message: "Error interno al modificar la persona"
            });
        }
        
    }
}


export {
    nuevaPersona,
    bajaPersona,
    altaPersona,
    getPersona,
    modificarPersona
}