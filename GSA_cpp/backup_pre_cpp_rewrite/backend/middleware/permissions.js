export function requireVerified(req, res, next) {
  if (!req.user?.verified) return res.status(403).json({ error: 'Verified required' });
  next();
}