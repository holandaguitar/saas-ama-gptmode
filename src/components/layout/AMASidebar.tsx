import React from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import {
  Home,
  Users,
  DollarSign,
  CreditCard,
  FileText,
  Scale,
  HelpCircle,
  Music,
} from 'lucide-react';
import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar,
} from "@/components/ui/sidebar";

const menuItems = [
  { title: "Dashboard", url: "/", icon: Home },
  { title: "Associados", url: "/associados", icon: Users },
  { title: "Financeiro", url: "/financeiro", icon: DollarSign },
  { title: "Contribuições", url: "/contribuicoes", icon: CreditCard },
  { title: "Convênios", url: "/convenios", icon: FileText },
  { title: "Jurídico", url: "/juridico", icon: Scale },
  { title: "Atendimento", url: "/atendimento", icon: HelpCircle },
];

export function AMASidebar() {
  const { state } = useSidebar();
  const location = useLocation();
  const currentPath = location.pathname;
  const isCollapsed = state === "collapsed";

  const isActive = (path: string) => currentPath === path;
  const getNavClassName = ({ isActive }: { isActive: boolean }) =>
    isActive 
      ? "bg-sidebar-primary text-sidebar-primary-foreground font-medium" 
      : "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground";

  return (
    <Sidebar collapsible="icon">
      <SidebarContent>
        {/* Logo Section */}
        <div className="p-4 border-b border-sidebar-border">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-sidebar-primary rounded-lg flex items-center justify-center">
              <Music className="w-6 h-6 text-sidebar-primary-foreground" />
            </div>
            {!isCollapsed && (
              <div>
                <h1 className="text-lg font-bold text-sidebar-foreground">AMA</h1>
                <p className="text-xs text-sidebar-foreground/70">Gestão Musical</p>
              </div>
            )}
          </div>
        </div>

        <SidebarGroup>
          <SidebarGroupLabel className="text-sidebar-foreground/70">
            {!isCollapsed && "Menu Principal"}
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {menuItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <NavLink 
                      to={item.url} 
                      end 
                      className={getNavClassName}
                    >
                      <item.icon className="w-5 h-5" />
                      {!isCollapsed && <span className="ml-3">{item.title}</span>}
                    </NavLink>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        {/* Footer */}
        {!isCollapsed && (
          <div className="mt-auto p-4 border-t border-sidebar-border">
            <div className="text-xs text-sidebar-foreground/50 text-center">
              © 2024 AMA - Associação dos Músicos Araguatinenses
            </div>
          </div>
        )}
      </SidebarContent>
    </Sidebar>
  );
}