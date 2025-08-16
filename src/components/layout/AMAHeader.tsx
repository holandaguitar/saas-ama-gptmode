import React from 'react';
import { SidebarTrigger } from "@/components/ui/sidebar";
import { LogOut, User } from 'lucide-react';
import { Button } from "@/components/ui/button";
import { useAuth } from '@/contexts/AuthContext';
import { useToast } from "@/components/ui/use-toast";

interface AMAHeaderProps {
  title: string;
}

export const AMAHeader: React.FC<AMAHeaderProps> = ({ title }) => {
  const { signOut, user } = useAuth();
  const { toast } = useToast();

  const handleSignOut = async () => {
    try {
      await signOut();
      toast({
        title: "Logout realizado",
        description: "Você foi desconectado com sucesso.",
      });
    } catch (error) {
      toast({
        title: "Erro no logout",
        description: "Ocorreu um erro ao desconectar.",
        variant: "destructive",
      });
    }
  };

  return (
    <header className="h-16 bg-sidebar border-b border-sidebar-border flex items-center justify-between px-6">
      <div className="flex items-center gap-4">
        <SidebarTrigger className="text-sidebar-foreground hover:bg-sidebar-accent" />
        <h1 className="text-xl font-semibold text-sidebar-foreground">{title}</h1>
      </div>
      
      <div className="flex items-center gap-3">
        <span className="text-sidebar-foreground text-sm">
          {user?.email}
        </span>
        <Button 
          variant="ghost" 
          size="icon"
          className="text-sidebar-foreground hover:bg-sidebar-accent"
        >
          <User className="w-5 h-5" />
        </Button>
        <Button 
          variant="ghost" 
          size="sm"
          className="text-sidebar-foreground hover:bg-sidebar-accent"
          onClick={handleSignOut}
        >
          <LogOut className="w-4 h-4 mr-2" />
          Sair
        </Button>
      </div>
    </header>
  );
};