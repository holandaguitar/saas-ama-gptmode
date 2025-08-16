import React, { useEffect, useState } from "react";
import { AMALayout } from "@/components/layout/AMALayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { supabase } from "@/integrations/supabase/client";
import { JuridicoModal } from "@/components/JuridicoModal";

type Row = any;

const Juridico = () => {
  const [items, setItems] = useState<Row[]>([]);

  async function fetchItems() {
    const { data, error } = await supabase.from("juridico").select("*").order("created_at", { ascending: false });
    if (error) console.error("Erro ao carregar juridico:", error);
    setItems(data ?? []);
  }

  useEffect(() => { fetchItems(); }, []);

  async function createItem(values: any) {
    const { error } = await supabase.from("juridico").insert([values]);
    if (error) console.error("Erro ao criar em juridico:", error);
    await fetchItems();
  }

  async function updateItem(values: any) {
    if (!values.id) return;
    const { error } = await supabase.from("juridico").update(values).eq("id", values.id);
    if (error) console.error("Erro ao atualizar em juridico:", error);
    await fetchItems();
  }

  async function deleteItem(id: string) {
    const { error } = await supabase.from("juridico").delete().eq("id", id);
    if (error) console.error("Erro ao excluir de juridico:", error);
    await fetchItems();
  }

  return (
    <AMALayout title="Juridico">
      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
          <div>
            <h1 className="text-2xl font-bold">Juridico</h1>
            <p className="text-muted-foreground">Gerencie registros da tabela juridico</p>
          </div>
          <JuridicoModal triggerLabel="Novo Registro" onSubmit={createItem} />
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
                      <JuridicoModal triggerLabel="Editar" initialData={row} onSubmit={updateItem} />
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

export default Juridico;
