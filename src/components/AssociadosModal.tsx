import React, { useEffect, useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

type Props = {
  triggerLabel: string;
  onSubmit: (data: any) => Promise<void> | void;
  initialData?: any | null;
};

export function AssociadosModal({ triggerLabel, onSubmit, initialData }: Props) {
  const [formData, setFormData] = useState<any>({});
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    setFormData(initialData ?? {});
  }, [initialData]);

  function handleChangeGeneric(e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) {
    const { name, value } = e.target;
    setFormData((prev: any) => ({ ...prev, [name]: value }));
    setErrors((prev) => ({ ...prev, [name]: "" }));
  }

  function validate(): boolean {
    const required: Record<string, string> = { "nome": "", "cpf": "", "email": "", "telefone": "", "endereco": "", "data_entrada": "" };
    const nextErrors: Record<string, string> = {};
    Object.keys(required).forEach((key) => {
      const val = (formData as any)[key];
      if (val === undefined || val === null || String(val).trim() === "") {
        nextErrors[key] = "Obrigatório";
      }
    });
    setErrors(nextErrors);
    return Object.keys(nextErrors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validate()) return;
    await onSubmit(formData);
  }

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>{triggerLabel}</Button>
      </DialogTrigger>
      <DialogContent className="max-w-lg w-full">
        <DialogHeader>
          <DialogTitle>Associados</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">nome</label>
            <input
              type="text"
              name="nome"
              value={formData["nome"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["nome"] && <span className="text-red-500 text-xs">{errors["nome"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">cpf</label>
            <input
              type="text"
              name="cpf"
              value={formData["cpf"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["cpf"] && <span className="text-red-500 text-xs">{errors["cpf"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">email</label>
            <input
              type="text"
              name="email"
              value={formData["email"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["email"] && <span className="text-red-500 text-xs">{errors["email"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">telefone</label>
            <input
              type="text"
              name="telefone"
              value={formData["telefone"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["telefone"] && <span className="text-red-500 text-xs">{errors["telefone"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">endereco</label>
            <input
              type="text"
              name="endereco"
              value={formData["endereco"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["endereco"] && <span className="text-red-500 text-xs">{errors["endereco"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">data_entrada</label>
            <input
              type="date"
              name="data_entrada"
              value={formData["data_entrada"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["data_entrada"] && <span className="text-red-500 text-xs">{errors["data_entrada"]}</span>}
          </div>
          <div className="flex justify-end gap-2">
            <Button type="submit">Salvar</Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
