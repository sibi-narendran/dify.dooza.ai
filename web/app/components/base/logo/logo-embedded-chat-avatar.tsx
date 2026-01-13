import type { FC } from 'react'
import { basePath } from '@/utils/var'

type LogoEmbeddedChatAvatarProps = {
  className?: string
}
const LogoEmbeddedChatAvatar: FC<LogoEmbeddedChatAvatarProps> = ({
  className,
}) => {
  // TODO: Add logo-embedded-chat-avatar.png (40x40) for better quality
  return (
    <img
      src={`${basePath}/logo/logo.png`}
      className={`block h-10 w-10 object-contain ${className}`}
      alt="Dooza logo"
    />
  )
}

export default LogoEmbeddedChatAvatar
