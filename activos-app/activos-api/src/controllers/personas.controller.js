import Persona from '../models/personas.models.js';

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
        return res.status(500).json({
            mensaje: 'error al crear la persona',
            error: error.message
        });
    }
}

export {
    nuevaPersona
}