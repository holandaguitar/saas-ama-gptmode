import React, { useEffect, useState } from "react";
import { AMALayout } from "@/components/layout/AMALayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { supabase } from "@/integrations/supabase/client";
import { ConveniosModal } from "@/components/ConveniosModal";

type Row = any;

const Convenios = () => {
  const [items, setItems] = useState<Row[]>([]);

  async function fetchItems() {
    const { data, error } = await supabase.from("convenios").select("*").order("created_at", { ascending: false });
    if (error) console.error("Erro ao carregar convenios:", error);
    setItems(data ?? []);
  }

  useEffect(() => { fetchItems(); }, []);

  async function createItem(values: any) {
    const { error } = await supabase.from("convenios").insert([values]);
    if (error) console.error("Erro ao criar em convenios:", error);
    await fetchItems();
  }

  async function updateItem(values: any) {
    if (!values.id) return;
    const { error } = await supabase.from("convenios").update(values).eq("id", values.id);
    if (error) console.error("Erro ao atualizar em convenios:", error);
    await fetchItems();
  }

  async function deleteItem(id: string) {
    const { error } = await supabase.from("convenios").delete().eq("id", id);
    if (error) console.error("Erro ao excluir de convenios:", error);
    await fetchItems();
  }

  return (
    <AMALayout title="Convenios">
      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
          <div>
            <h1 className="text-2xl font-bold">Convenios</h1>
            <p className="text-muted-foreground">Gerencie registros da tabela convenios</p>
          </div>
          <ConveniosModal triggerLabel="Novo Registro" onSubmit={createItem} />
        </div>

        <Card className="shadow-card">
          <CardHeader><CardTitle>Registros</CardTitle></CardHeader>
          <CardContent>
            {items.length === 0 ? (
              <p className="text-muted-foreground">Nenhum registro encontrado.</p>
            ) : (
              <div className="divide-y rounded border">
                {items.map((row: any) => (
                  <div key={row.id} className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 p-3">
                    <pre className="text-xs sm:text-sm whitespace-pre-wrap break-words flex-1">{JSON.stringify(row, null, 2)}</pre>
                    <div className="flex gap-2 justify-end">
                      <ConveniosModal triggerLabel="Editar" initialData={row} onSubmit={updateItem} />
                      <Button variant="destructive" onClick={() => deleteItem(row.id)}>Excluir</Button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </AMALayout>
  );
};

export default Convenios;
