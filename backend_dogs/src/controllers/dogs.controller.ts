import { Request, Response } from "express";
import { Dogs, DogsI } from "../models/Dogs";

export class DogsController {
  // Obtener todas las perros activas
  public async getAllDogs(req: Request, res: Response) {
    try {
      const dogs: DogsI[] = await Dogs.findAll({
        where: { status: 'ACTIVE' },
      });
      res.status(200).json({ dogs });
    } catch (error) {
      res.status(500).json({ error: "Error al obtener las perros" });
    }
  }

  // Obtener una perro por su ID
  public async getDogsById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const singleDogs = await Dogs.findOne({
        where: { id: pk, status: 'ACTIVE' },
      });
      if (singleDogs) {
        res.status(200).json({ dogs: singleDogs });
      } else {
        res.status(404).json({ error: "Perro no encontrada o inactiva" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error al obtener la perro" });
    }
  }

  // Crear una nueva perro
  public async createDogs(req: Request, res: Response) {
    const { birthday, value_dog, breeds_id, status } = req.body;
    try {
      let body: DogsI = { birthday, value_dog, breeds_id, status };
      const newDogs = await Dogs.create({ ...body });
      res.status(201).json(newDogs);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  // Actualizar una perro existente
  public async updateDogs(req: Request, res: Response) {
    const { id: pk } = req.params;
    const { birthday, value_dog, breeds_id, status } = req.body;
    try {
      let body: DogsI = { birthday, value_dog, breeds_id, status };
      const dogsExist = await Dogs.findOne({
        where: { id: pk, status: 'ACTIVE' },
      });

      if (dogsExist) {
        await dogsExist.update(body, { where: { id: pk } });
        res.status(200).json(dogsExist);
      } else {
        res.status(404).json({ error: "Perro no encontrada o inactiva" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  // Eliminar una perro físicamente
  public async deleteDogs(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const dogsToDelete = await Dogs.findByPk(id);

      if (dogsToDelete) {
        await dogsToDelete.destroy();
        res.status(200).json({ message: "Perro eliminada exitosamente" });
      } else {
        res.status(404).json({ error: "Perro no encontrada" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error al eliminar la perro" });
    }
  }

  // Eliminar una perro lógicamente (cambiar status a "INACTIVE")
  public async deleteDogsAdv(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const dogsToUpdate = await Dogs.findOne({
        where: { id: pk, status: 'ACTIVE' },
      });

      if (dogsToUpdate) {
        await dogsToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Perro marcada como inactiva" });
      } else {
        res.status(404).json({ error: "Perro no encontrada" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error al marcar la perro como inactiva" });
    }
  }
}