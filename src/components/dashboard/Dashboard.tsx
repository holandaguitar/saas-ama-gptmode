import React from 'react';
import { Users, DollarSign, CreditCard, TrendingUp } from 'lucide-react';
import { StatsCard } from './StatsCard';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export const Dashboard: React.FC = () => {
  // Mock data - será substituído por dados reais do Supabase
  const stats = [
    {
      title: "Total de Associados",
      value: "142",
      change: "+5 este mês",
      icon: Users,
      trend: 'up' as const
    },
    {
      title: "Receita Mensal",
      value: "R$ 12.450",
      change: "+12% vs mês anterior",
      icon: DollarSign,
      trend: 'up' as const
    },
    {
      title: "Contribuições em Dia",
      value: "87%",
      change: "125 de 142 associados",
      icon: CreditCard,
      trend: 'neutral' as const
    },
    {
      title: "Crescimento Anual",
      value: "+24%",
      change: "Meta: 20%",
      icon: TrendingUp,
      trend: 'up' as const
    }
  ];

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-foreground">
            Bem-vindo ao AMA
          </h1>
          <p className="text-muted-foreground mt-1">
            Painel de gestão da Associação dos Músicos Araguatinenses
          </p>
        </div>
        <div className="text-right">
          <p className="text-sm text-muted-foreground">
            Última atualização
          </p>
          <p className="text-sm font-medium text-foreground">
            {new Date().toLocaleDateString('pt-BR')} às {new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
          </p>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat, index) => (
          <StatsCard key={index} {...stat} />
        ))}
      </div>

      {/* Recent Activity & Quick Actions */}
      <div className="grid gap-6 md:grid-cols-2">
        {/* Recent Activity */}
        <Card className="shadow-card">
          <CardHeader>
            <CardTitle className="text-lg font-semibold text-foreground">
              Atividades Recentes
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center space-x-3 p-3 bg-muted rounded-lg">
              <div className="w-2 h-2 bg-primary rounded-full"></div>
              <div className="flex-1">
                <p className="text-sm font-medium text-foreground">
                  Novo associado registrado
                </p>
                <p className="text-xs text-muted-foreground">
                  João Silva - Violonista • Há 2 horas
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-3 p-3 bg-muted rounded-lg">
              <div className="w-2 h-2 bg-green-500 rounded-full"></div>
              <div className="flex-1">
                <p className="text-sm font-medium text-foreground">
                  Contribuição recebida
                </p>
                <p className="text-xs text-muted-foreground">
                  Maria Santos - R$ 150,00 • Há 4 horas
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-3 p-3 bg-muted rounded-lg">
              <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
              <div className="flex-1">
                <p className="text-sm font-medium text-foreground">
                  Documento atualizado
                </p>
                <p className="text-xs text-muted-foreground">
                  Regulamento 2024 • Há 1 dia
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Quick Actions */}
        <Card className="shadow-card">
          <CardHeader>
            <CardTitle className="text-lg font-semibold text-foreground">
              Ações Rápidas
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <button className="w-full p-3 text-left bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-smooth">
              <div className="font-medium">Cadastrar Novo Associado</div>
              <div className="text-sm opacity-90">Adicionar membro à associação</div>
            </button>
            <button className="w-full p-3 text-left bg-secondary text-secondary-foreground rounded-lg hover:bg-secondary/80 transition-smooth">
              <div className="font-medium">Registrar Contribuição</div>
              <div className="text-sm opacity-75">Lançar pagamento de associado</div>
            </button>
            <button className="w-full p-3 text-left bg-secondary text-secondary-foreground rounded-lg hover:bg-secondary/80 transition-smooth">
              <div className="font-medium">Gerar Relatório</div>
              <div className="text-sm opacity-75">Exportar dados financeiros</div>
            </button>
          </CardContent>
        </Card>
      </div>

      {/* Music Note Decoration */}
      <div className="relative music-note">
        <div className="absolute -bottom-4 -right-4 text-6xl text-primary/5 select-none pointer-events-none">
          ♪ ♫ ♪
        </div>
      </div>
    </div>
  );
};