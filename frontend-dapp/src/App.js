import './App.css';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Store from './pages/Store';
import NavBarDApp from './components/NavBarDApp';
import Dashboard from './pages/Dashboard';
import Footer from './components/Footer';

function App() {
  return (
    <BrowserRouter>
    <NavBarDApp />
      <Routes>
         <Route path="/" element={<Store />} />
         <Route path="/store" element={<Store />} />
         <Route path="/dashboard" element={<Dashboard />} />
      </Routes>
      <Footer />
    </BrowserRouter>
  );
}

export default App;
