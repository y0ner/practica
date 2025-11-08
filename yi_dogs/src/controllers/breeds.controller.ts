import { Request, Response } from "express";
import { Breeds, BreedsI } from "../models/Breeds";

export class BreedsController {
  // Obtener todos los autores activos
  public async getAllBreedss(req: Request, res: Response) {
    try {
      const breeds: BreedsI[] = await Breeds.findAll({
        where: { status: 'ACTIVE' },
      });
      res.status(200).json({ breeds });
    } catch (error) {
      res.status(500).json({ error: "Error al obtener los autores" });
    }
  }

  // Obtener un autor por su ID
  public async getBreedsById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const breeds = await Breeds.findOne({
        where: { id: pk, status: 'ACTIVE' },
      });
      if (breeds) {
        res.status(200).json({ breeds });
      } else {
        res.status(404).json({ error: "Autor no encontrado o inactivo" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error al obtener el autor" });
    }
  }

  // Crear un nuevo autor
  public async createBreeds(req: Request, res: Response) {
    const { name, status } = req.body;
    try {
      let body: BreedsI = { name, status };
      const newBreeds = await Breeds.create({ ...body });
      res.status(201).json(newBreeds);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  // Actualizar un autor existente
  public async updateBreeds(req: Request, res: Response) {
    const { id: pk } = req.params;
    const { name, status } = req.body;
    try {
      let body: BreedsI = { name, status };
      const breedsExist = await Breeds.findOne({
        where: { id: pk, status: 'ACTIVE' },
      });

      if (breedsExist) {
        await breedsExist.update(body, { where: { id: pk } });
        res.status(200).json(breedsExist);
      } else {
        res.status(404).json({ error: "Autor no encontrado o inactivo" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  // Eliminar un autor físicamente
  public async deleteBreeds(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const breedsToDelete = await Breeds.findByPk(id);

      if (breedsToDelete) {
        await breedsToDelete.destroy();
        res.status(200).json({ message: "Autor eliminado exitosamente" });
      } else {
        res.status(404).json({ error: "Autor no encontrado" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error al eliminar el autor" });
    }
  }

  // Eliminar un autor lógicamente (cambiar status a "INACTIVE")
  public async deleteBreedsAdv(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const breedsToUpdate = await Breeds.findOne({
        where: { id: pk, status: 'ACTIVE' },
      });

      if (breedsToUpdate) {
        await breedsToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Autor marcado como inactivo" });
      } else {
        res.status(404).json({ error: "Autor no encontrado" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error al marcar el autor como inactivo" });
    }
  }
}