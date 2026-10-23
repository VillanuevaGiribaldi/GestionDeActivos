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
        catchSQL45000(res, error, "No se pudo crear la persona")
        return res.status(500).json({
            mensaje: 'error al crear la persona'
        });
    }
}

const getPersona = async (req,res) => {
    try {
        
    } catch (error) {
        
    }
}
export {
    nuevaPersona
}