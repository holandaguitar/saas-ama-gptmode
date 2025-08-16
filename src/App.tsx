import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "@/contexts/AuthContext";
import ProtectedRoute from "@/components/ProtectedRoute";
import Index from "./pages/Index";
import Auth from "./pages/Auth";
import Associados from "./pages/Associados";
import Financeiro from "./pages/Financeiro";
import Contribuicoes from "./pages/Contribuicoes";
import Convenios from "./pages/Convenios";
import Juridico from "./pages/Juridico";
import Atendimento from "./pages/Atendimento";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <Routes>
            <Route path="/auth" element={<Auth />} />
            <Route path="/" element={
              <ProtectedRoute>
                <Index />
              </ProtectedRoute>
            } />
            <Route path="/associados" element={
              <ProtectedRoute>
                <Associados />
              </ProtectedRoute>
            } />
            <Route path="/financeiro" element={
              <ProtectedRoute>
                <Financeiro />
              </ProtectedRoute>
            } />
            <Route path="/contribuicoes" element={
              <ProtectedRoute>
                <Contribuicoes />
              </ProtectedRoute>
            } />
            <Route path="/convenios" element={
              <ProtectedRoute>
                <Convenios />
              </ProtectedRoute>
            } />
            <Route path="/juridico" element={
              <ProtectedRoute>
                <Juridico />
              </ProtectedRoute>
            } />
            <Route path="/atendimento" element={
              <ProtectedRoute>
                <Atendimento />
              </ProtectedRoute>
            } />
            {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
            <Route path="*" element={<NotFound />} />
          </Routes>
        </BrowserRouter>
      </TooltipProvider>
    </AuthProvider>
  </QueryClientProvider>
);

export default App;
