export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.4"
  }
  public: {
    Tables: {
      associados: {
        Row: {
          cpf: string
          created_at: string
          data_ingresso: string | null
          endereco: string | null
          foto_url: string | null
          id: string
          id_usuario: string | null
          instrumento: string | null
          nome_completo: string
          profissao: string | null
          status: Database["public"]["Enums"]["associado_status"]
          telefone: string | null
          updated_at: string
        }
        Insert: {
          cpf: string
          created_at?: string
          data_ingresso?: string | null
          endereco?: string | null
          foto_url?: string | null
          id?: string
          id_usuario?: string | null
          instrumento?: string | null
          nome_completo: string
          profissao?: string | null
          status?: Database["public"]["Enums"]["associado_status"]
          telefone?: string | null
          updated_at?: string
        }
        Update: {
          cpf?: string
          created_at?: string
          data_ingresso?: string | null
          endereco?: string | null
          foto_url?: string | null
          id?: string
          id_usuario?: string | null
          instrumento?: string | null
          nome_completo?: string
          profissao?: string | null
          status?: Database["public"]["Enums"]["associado_status"]
          telefone?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      atendimentos: {
        Row: {
          created_at: string
          data_abertura: string
          data_conclusao: string | null
          descricao: string
          id: string
          id_associado: string
          id_usuario_responsavel: string | null
          status: Database["public"]["Enums"]["atendimento_status"]
          updated_at: string
        }
        Insert: {
          created_at?: string
          data_abertura?: string
          data_conclusao?: string | null
          descricao: string
          id?: string
          id_associado: string
          id_usuario_responsavel?: string | null
          status?: Database["public"]["Enums"]["atendimento_status"]
          updated_at?: string
        }
        Update: {
          created_at?: string
          data_abertura?: string
          data_conclusao?: string | null
          descricao?: string
          id?: string
          id_associado?: string
          id_usuario_responsavel?: string | null
          status?: Database["public"]["Enums"]["atendimento_status"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "atendimentos_id_associado_fkey"
            columns: ["id_associado"]
            isOneToOne: false
            referencedRelation: "associados"
            referencedColumns: ["id"]
          },
        ]
      }
      categorias_financeiras: {
        Row: {
          created_at: string
          descricao: string | null
          id: string
          nome: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          descricao?: string | null
          id?: string
          nome: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          descricao?: string | null
          id?: string
          nome?: string
          updated_at?: string
        }
        Relationships: []
      }
      contribuicoes: {
        Row: {
          created_at: string
          data_pagamento: string | null
          id: string
          id_associado: string
          recibo_url: string | null
          status: Database["public"]["Enums"]["contribuicao_status"]
          updated_at: string
          valor: number
        }
        Insert: {
          created_at?: string
          data_pagamento?: string | null
          id?: string
          id_associado: string
          recibo_url?: string | null
          status?: Database["public"]["Enums"]["contribuicao_status"]
          updated_at?: string
          valor: number
        }
        Update: {
          created_at?: string
          data_pagamento?: string | null
          id?: string
          id_associado?: string
          recibo_url?: string | null
          status?: Database["public"]["Enums"]["contribuicao_status"]
          updated_at?: string
          valor?: number
        }
        Relationships: [
          {
            foreignKeyName: "contribuicoes_id_associado_fkey"
            columns: ["id_associado"]
            isOneToOne: false
            referencedRelation: "associados"
            referencedColumns: ["id"]
          },
        ]
      }
      convenios: {
        Row: {
          beneficios: string | null
          created_at: string
          data_fim: string | null
          data_inicio: string | null
          descricao: string | null
          id: string
          nome_parceiro: string
          status: Database["public"]["Enums"]["convenio_status"]
          updated_at: string
        }
        Insert: {
          beneficios?: string | null
          created_at?: string
          data_fim?: string | null
          data_inicio?: string | null
          descricao?: string | null
          id?: string
          nome_parceiro: string
          status?: Database["public"]["Enums"]["convenio_status"]
          updated_at?: string
        }
        Update: {
          beneficios?: string | null
          created_at?: string
          data_fim?: string | null
          data_inicio?: string | null
          descricao?: string | null
          id?: string
          nome_parceiro?: string
          status?: Database["public"]["Enums"]["convenio_status"]
          updated_at?: string
        }
        Relationships: []
      }
      financeiro: {
        Row: {
          categoria: string | null
          created_at: string
          data_lancamento: string
          descricao: string | null
          id: string
          id_usuario_responsavel: string | null
          tipo: Database["public"]["Enums"]["financeiro_tipo"]
          updated_at: string
          valor: number
        }
        Insert: {
          categoria?: string | null
          created_at?: string
          data_lancamento: string
          descricao?: string | null
          id?: string
          id_usuario_responsavel?: string | null
          tipo: Database["public"]["Enums"]["financeiro_tipo"]
          updated_at?: string
          valor: number
        }
        Update: {
          categoria?: string | null
          created_at?: string
          data_lancamento?: string
          descricao?: string | null
          id?: string
          id_usuario_responsavel?: string | null
          tipo?: Database["public"]["Enums"]["financeiro_tipo"]
          updated_at?: string
          valor?: number
        }
        Relationships: []
      }
      historico_contribuicoes: {
        Row: {
          acao: string
          created_at: string
          data_acao: string
          id: string
          id_contribuicao: string
          id_usuario_responsavel: string | null
          updated_at: string
        }
        Insert: {
          acao: string
          created_at?: string
          data_acao?: string
          id?: string
          id_contribuicao: string
          id_usuario_responsavel?: string | null
          updated_at?: string
        }
        Update: {
          acao?: string
          created_at?: string
          data_acao?: string
          id?: string
          id_contribuicao?: string
          id_usuario_responsavel?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "historico_contribuicoes_id_contribuicao_fkey"
            columns: ["id_contribuicao"]
            isOneToOne: false
            referencedRelation: "contribuicoes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "historico_contribuicoes_id_usuario_responsavel_fkey"
            columns: ["id_usuario_responsavel"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      juridico: {
        Row: {
          arquivo_url: string
          created_at: string
          data_upload: string
          id: string
          id_usuario_responsavel: string | null
          tipo_documento: Database["public"]["Enums"]["juridico_tipo"]
          titulo: string
          updated_at: string
        }
        Insert: {
          arquivo_url: string
          created_at?: string
          data_upload?: string
          id?: string
          id_usuario_responsavel?: string | null
          tipo_documento: Database["public"]["Enums"]["juridico_tipo"]
          titulo: string
          updated_at?: string
        }
        Update: {
          arquivo_url?: string
          created_at?: string
          data_upload?: string
          id?: string
          id_usuario_responsavel?: string | null
          tipo_documento?: Database["public"]["Enums"]["juridico_tipo"]
          titulo?: string
          updated_at?: string
        }
        Relationships: []
      }
      logs_atendimentos: {
        Row: {
          created_at: string
          data_acao: string
          descricao_acao: string
          id: string
          id_atendimento: string
          id_usuario_responsavel: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          data_acao?: string
          descricao_acao: string
          id?: string
          id_atendimento: string
          id_usuario_responsavel?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          data_acao?: string
          descricao_acao?: string
          id?: string
          id_atendimento?: string
          id_usuario_responsavel?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "logs_atendimentos_id_atendimento_fkey"
            columns: ["id_atendimento"]
            isOneToOne: false
            referencedRelation: "atendimentos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "logs_atendimentos_id_usuario_responsavel_fkey"
            columns: ["id_usuario_responsavel"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          email: string | null
          id: string
          nome: string | null
          telefone: string | null
          tipo_usuario: Database["public"]["Enums"]["tipo_usuario"]
          updated_at: string
        }
        Insert: {
          created_at?: string
          email?: string | null
          id: string
          nome?: string | null
          telefone?: string | null
          tipo_usuario?: Database["public"]["Enums"]["tipo_usuario"]
          updated_at?: string
        }
        Update: {
          created_at?: string
          email?: string | null
          id?: string
          nome?: string | null
          telefone?: string | null
          tipo_usuario?: Database["public"]["Enums"]["tipo_usuario"]
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      current_user_role: {
        Args: Record<PropertyKey, never>
        Returns: Database["public"]["Enums"]["tipo_usuario"]
      }
      is_admin: {
        Args: Record<PropertyKey, never>
        Returns: boolean
      }
      is_operator: {
        Args: Record<PropertyKey, never>
        Returns: boolean
      }
    }
    Enums: {
      associado_status: "ativo" | "inativo" | "suspenso"
      atendimento_status: "em_andamento" | "concluido"
      contribuicao_status: "pendente" | "pago" | "atrasado"
      convenio_status: "ativo" | "encerrado"
      financeiro_tipo: "receita" | "despesa"
      juridico_tipo: "contrato" | "ata" | "regulamento" | "outro"
      tipo_usuario: "admin" | "operador" | "associado"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      associado_status: ["ativo", "inativo", "suspenso"],
      atendimento_status: ["em_andamento", "concluido"],
      contribuicao_status: ["pendente", "pago", "atrasado"],
      convenio_status: ["ativo", "encerrado"],
      financeiro_tipo: ["receita", "despesa"],
      juridico_tipo: ["contrato", "ata", "regulamento", "outro"],
      tipo_usuario: ["admin", "operador", "associado"],
    },
  },
} as const
