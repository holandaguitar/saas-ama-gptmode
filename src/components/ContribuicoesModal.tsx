import React, { useEffect, useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

type Props = {
  triggerLabel: string;
  onSubmit: (data: any) => Promise<void> | void;
  initialData?: any | null;
};

export function ContribuicoesModal({ triggerLabel, onSubmit, initialData }: Props) {
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
    const required: Record<string, string> = { "associado_id": "", "valor": "", "data_pagamento": "", "status": "" };
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
          <DialogTitle>Contribuicoes</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">associado_id</label>
            <input
              type="text"
              name="associado_id"
              value={formData["associado_id"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["associado_id"] && <span className="text-red-500 text-xs">{errors["associado_id"]}</span>}
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
            <label className="text-sm text-muted-foreground">data_pagamento</label>
            <input
              type="date"
              name="data_pagamento"
              value={formData["data_pagamento"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            />
            {errors["data_pagamento"] && <span className="text-red-500 text-xs">{errors["data_pagamento"]}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm text-muted-foreground">status</label>
            <select
              name="status"
              value={formData["status"] ?? ""}
              onChange={handleChangeGeneric}
              required
              className="border rounded p-2 w-full focus:outline-none focus:ring focus:ring-primary/30"
            >
              <option value="">Selecione</option>
              <option value="pago">pago</option>
              <option value="pendente">pendente</option>
            </select>
            {errors["status"] && <span className="text-red-500 text-xs">{errors["status"]}</span>}
          </div>
          <div className="flex justify-end gap-2">
            <Button type="submit">Salvar</Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
