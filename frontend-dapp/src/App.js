import './App.css';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Store from './pages/Store';
import NavBarDApp from './components/NavBarDApp';
import Dashboard from './pages/Dashboard';

function App() {
  return (
    <BrowserRouter>
    <NavBarDApp />
      <Routes>
         <Route path="/" element={<Store />} />
         <Route path="/store" element={<Store />} />
         <Route path="/dashboard" element={<Dashboard />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
