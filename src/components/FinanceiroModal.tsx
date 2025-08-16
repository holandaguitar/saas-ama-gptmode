import React, { useEffect, useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

type Props = {
  triggerLabel: string;
  onSubmit: (data: any) => Promise<void> | void;
  initialData?: any | null;
};

export function FinanceiroModal({ triggerLabel, onSubmit, initialData }: Props) {
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
    const required: Record<string, string> = { "descricao": "", "valor": "", "tipo": "", "data": "" };
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
          <DialogTitle>Financeiro</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">descricao</label>
            <input
              type="text"
              name="descricao"
              value={formData["descricao"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["descricao"] && <span className="text-red-500 text-xs">{errors["descricao"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">valor</label>
            <input
              type="number"
              name="valor"
              value={formData["valor"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["valor"] && <span className="text-red-500 text-xs">{errors["valor"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">tipo</label>
            <select
              name="tipo"
              value={formData["tipo"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            >
              <option value="">Selecione</option>
              <option value="receita">receita</option>
              <option value="despesa">despesa</option>
            </select>
            {errors["tipo"] && <span className="text-red-500 text-xs">{errors["tipo"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">data</label>
            <input
              type="date"
              name="data"
              value={formData["data"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["data"] && <span className="text-red-500 text-xs">{errors["data"]}</span>}
          </div>
          <div className="flex justify-end gap-2">
            <Button type="submit">Salvar</Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
